require 'excon'
require 'json'
require 'pp'

METAL_UUID="f9e7e6b4-d5dc-4136-a445-d3adffc23bc6"
FACTORY_UUID="d9c166f0-3c6d-11e4-801e-d5aa4697630f"
FIGHTER_UUID="6e573ecc-557b-4e05-9f3b-511b2611c474"
SCAFFOLD_UUID='ffb74468-7162-4bfb-8a0e-a8ae72ef2a8b'

auth = Excon.new('http://localhost:5200', persistent: true)

def basic_auth(user, password)
  'Basic ' << ['' << user.to_s << ':' << password.to_s].pack('m').delete(Excon::CR_NL)
end

begin
  resp = JSON.parse(auth.post(
    path: '/accounts',
    body: {
    secret: "bob",
    privileged: true # a privileged account means we are part of the game itself
  }.to_json,
    headers: { "Content-Type" => "application/json" },
    expects: 200
  ).body)

  pp resp

  resp = JSON.parse(auth.get(
    path: '/auth',
    headers: {
    # We have to do this because the basic auth credentials are only for this endpoint
    "Authorization" => basic_auth(resp['account'], 'bob'),
    "Content-Type" => "application/json"
  },
    expects: 200
  ).body)

  pp resp
  auth_token = resp['token']

  build = Excon.new('http://localhost:5300', persistent: true,
                        headers: { 
    "Authorization" => "Bearer #{auth_token}",
    "Content-Type" => "application/json"
  }, debug: true)

  inventory = Excon.new('http://localhost:5400', persistent: true,
                        headers: { 
    "Authorization" => "Bearer #{auth_token}",
    "Content-Type" => "application/json"
  }, debug: true)

  uuid = "toy-factory"

  # TODO spodb should do this
  inventory.post(
    path: '/containers/toy-factory',
    body: { blueprint: FACTORY_UUID }.to_json,
    expects: 204
  )

  # TODO spodb should do this
  build.post(
    path: "/facilities/toy-factory",
    body: { blueprint: FACTORY_UUID }.to_json,
    headers: { "Content-Type" => "application/json" },
    expects: 201
  )

  pp JSON.parse(inventory.get(path: '/inventory/toy-factory', expects: 200).body)

  pp JSON.parse(inventory.get(path: '/inventory', expects: 200).body)

  inventory.post(
    path: "/inventory",
    body: [{
      inventory: uuid,
      slice: "default",
      blueprint: METAL_UUID,
      quantity: 35
    }].to_json,
    expects: 204
  )

  pp JSON.parse(inventory.get(
    path: '/inventory',
    expects: 200
  ).body)

  build.post(
    path: "/jobs",
    body: {
      facility: uuid,
      action: "manufacture",
      quantity: 1,
      target: FIGHTER_UUID,
      inventory: 'default'
    }.to_json,
    headers: { "Content-Type" => "application/json" },
    expects: 201
  )

  pp JSON.parse(build.get(path: '/jobs').body)

  puts "waiting for the job to finish"
  sleep 35

  pp JSON.parse(inventory.get(
    path: '/inventory',
    headers: { "Authorization" => "Bearer #{auth_token}"},
    expects: 200
  ).body)

rescue Excon::Errors::HTTPStatusError
  puts $!.response.body
  raise
end
