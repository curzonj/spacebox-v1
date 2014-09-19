require 'excon'
require 'json'
require 'pp'

METAL_UUID="f9e7e6b4-d5dc-4136-a445-d3adffc23bc6"
FACTORY_UUID="d9c166f0-3c6d-11e4-801e-d5aa4697630f"

inventory = Excon.new('http://localhost:5400', persistent: true)
build = Excon.new('http://localhost:5300', persistent: true)

begin

  uuid = "toy-factory"

  inventory.post(
    path: '/containers/toy-factory',
    body: { blueprint: FACTORY_UUID }.to_json,
    headers: { "Content-Type" => "application/json" }
  )

  pp JSON.parse(inventory.get(path: '/inventory').body)

  inventory.post(
    path: "/inventory",
    body: [{
      inventory: uuid,
      slice: "default",
      blueprint: METAL_UUID,
      quantity: 35
    }].to_json,
    headers: { "Content-Type" => "application/json" },
    expects: [ 204 ]
  )

  pp JSON.parse(inventory.get(path: '/inventory').body)

  # TODO spodb should do this
  build.post(
    path: "/facilities",
    body: {
      uuid: uuid,
      blueprint: FACTORY_UUID
    }.to_json,
    headers: { "Content-Type" => "application/json" },
    expects: [ 201 ]
  )

  build.post(
    path: "/jobs",
    body: {
      facility: uuid,
      action: "manufacture",
      quantity: 1,
      target: 'ffb74468-7162-4bfb-8a0e-a8ae72ef2a8b',
      inventory: 'default'
    }.to_json,
    headers: { "Content-Type" => "application/json" },
    expects: [ 201 ]
  )

  pp JSON.parse(build.get(path: '/jobs').body)

  puts "waiting for the job to finish"
  sleep 15

  pp JSON.parse(inventory.get(path: '/inventory').body)
rescue Excon::Errors::HTTPStatusError
  puts $!.response.body
  raise
end
