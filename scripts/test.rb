require 'excon'
require 'json'
require 'pp'
require 'uuid'

METAL_UUID="f9e7e6b4-d5dc-4136-a445-d3adffc23bc6"
FACTORY_UUID="d9c166f0-3c6d-11e4-801e-d5aa4697630f"
FIGHTER_UUID="6e573ecc-557b-4e05-9f3b-511b2611c474"
SCAFFOLD_UUID='ffb74468-7162-4bfb-8a0e-a8ae72ef2a8b'
ORE_MINE_UUID='33e24278-4d46-4146-946e-58a449d5afae'

uuidGen = UUID.new
auth = Excon.new('http://localhost:5200', persistent: true)

def basic_auth(user, password)
  'Basic ' << ['' << user.to_s << ':' << password.to_s].pack('m').delete(Excon::CR_NL)
end

begin
  # create our account and login
  resp = JSON.parse(auth.post(
    path: '/accounts',
    body: {
      secret: "bob",
      #privileged: true # a privileged account means we are part of the game itself
    }.to_json,
    headers: { "Content-Type" => "application/json" },
    expects: 200
  ).body)

  resp = JSON.parse(auth.get(
    path: '/auth',
    headers: {
    # We have to do this because the basic auth credentials are only for this endpoint
      "Authorization" => basic_auth(resp['account'], 'bob'),
      "Content-Type" => "application/json"
    },
    expects: 200
  ).body)

  auth_token = resp['token']

  build = Excon.new('http://localhost:5300', persistent: true,
                        headers: { 
    "Authorization" => "Bearer #{auth_token}",
    "Content-Type" => "application/json"
  })

  inventory = Excon.new('http://localhost:5400', persistent: true,
                        headers: { 
    "Authorization" => "Bearer #{auth_token}",
    "Content-Type" => "application/json"
  })

  # Get our account setup
  puts build.get(path: "/setup?loadout=starter", expects: 200).body

  myContainers = JSON.parse(inventory.get(path: '/inventory', expects: 200).body)
  pp 'mycontainers', myContainers

  uuid = myContainers.keys.first

  pp 'my facilities', JSON.parse(build.get(path: '/facilities', expects: 200).body)

  # Build a scaffolding in our initial factory
  5.times do 
    build.post(
      path: "/jobs",
      body: {
        facility: uuid,
        action: "manufacture",
        quantity: 1,
        target: SCAFFOLD_UUID,
        slice: 'default'
      }.to_json,
      headers: { "Content-Type" => "application/json" },
      expects: 201
    )
  end

  pp 'my jobs', JSON.parse(build.get(path: '/jobs').body)

  puts "waiting for the job to finish"
  sleep 10

  pp 'inventory', JSON.parse(inventory.get( path: '/inventory', expects: 200).body)

  scaffold = uuidGen.generate

  puts "deploying #{scaffold} scaffold"

  # deploy the new scaffolding and put 2 metal in it
  inventory.post(
    path: "/inventory",
    body: [{
      inventory: uuid,
      slice: "default",
      blueprint: SCAFFOLD_UUID,
      quantity: -1
    },{
      inventory: uuid,
      slice: "default",
      blueprint: METAL_UUID,
      quantity: -2
    },{
      inventory: scaffold,
      slice: "default",
      blueprint: METAL_UUID,
      quantity: 2
    },{
      container_action: 'create',
      uuid: scaffold,
      blueprint: SCAFFOLD_UUID
    }].to_json,
    expects: 204
  )


  ## we have to manually tell the build api that there
  ## is a new facility because spodb isn't ready yet
  ## Don't worry, this gets verified by inventory
  puts "building new ore mine on #{scaffold}"
  build.post(
    path: "/facilities/#{scaffold}",
    body: { blueprint: SCAFFOLD_UUID }.to_json,
    expects: 201
  )

  pp 'inventory', JSON.parse(inventory.get( path: '/inventory', expects: 200).body)

  # Build an ore mine on our new scaffolding
  puts "building new ore mine on #{scaffold}"
  build.post(
    path: "/jobs",
    body: {
      facility: scaffold,
      action: "construct",
      quantity: 1,
      target: ORE_MINE_UUID,
      slice: 'default'
    }.to_json,
    expects: 201
  )

  pp 'jobs', JSON.parse(build.get(path: '/jobs').body)

  sleep 10

  pp 'jobs', JSON.parse(build.get(path: '/jobs').body)

  ## TODO the build api should tell inventory that the
  ## blueprint of the structure has changed
 
  puts "upgraded #{scaffold} to a #{ORE_MINE_UUID}"
  pp 'inventory', JSON.parse(inventory.get( path: '/inventory', expects: 200).body)

rescue Excon::Errors::HTTPStatusError
  puts $!.response.body
  raise
end
