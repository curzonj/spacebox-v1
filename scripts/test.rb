require 'excon'
require 'json'
require 'pp'

METAL_UUID="f9e7e6b4-d5dc-4136-a445-d3adffc23bc6"
FACTORY_UUID="d9c166f0-3c6d-11e4-801e-d5aa4697630f"

spodb = Excon.new('http://localhost:5100', :persistent => true)
inventory = Excon.new('http://localhost:5400', :persistent => true)
build = Excon.new('http://localhost:5300', :persistent => true)

begin
  obj = {
    type: "structure",
    blueprint: FACTORY_UUID,
    name: "factory"
  }

  uuid = spodb.post(
    path: '/spodb',
    body: obj.to_json,
    headers: { "Content-Type" => "application/json" }
  ).body

  puts uuid

  pp JSON.parse(spodb.get(path: '/spodb').body)

  inventory.post(
    path: "/inventory/#{uuid}/default",
    body: { type: METAL_UUID, quantity: 35 }.to_json,
    headers: { "Content-Type" => "application/json" },
    expects: [ 200 ]
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
rescue Excon::Errors::HTTPStatusError
  puts $!.response.body
  raise
end
