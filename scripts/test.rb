require 'excon'
require 'json'
require 'pp'

METAL_UUID="f9e7e6b4-d5dc-4136-a445-d3adffc23bc6"

spodb = Excon.new('http://localhost:5100', :persistent => true)
inventory = Excon.new('http://localhost:5400', :persistent => true)

obj = {
  type: "structure",
  name: "factory"
}

uuid = spodb.post(
  path: '/spodb',
  body: obj.to_json,
  headers: { "Content-Type" => "application/json" }
).body

inventory.post(
  path: "/inventory/#{uuid}/default",
  body: { type: METAL_UUID, quantity: 35 }.to_json,
  headers: { "Content-Type" => "application/json" },
  expects: [ 200 ]
).body

pp JSON.parse(inventory.get(path: '/inventories').body)
