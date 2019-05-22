# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.create!({
  email: 'demo@mail.com',
  last_name: 'Seed user',
  state: 'active',
  password: '123123',
  is_enabled_2fa: true,
})

session = Session.create!({
  user: user,
})
client = Client.create!({
  name: 'seed client',
  state: 'active',
  # currency: 'rub',
  # writeoff_type: 'prepaid',
  # writeoff_interval: 0,
  # business_entity_type: 'individual',
})
role = Role.create_admin_role(client)
profile = Profile.create!({
  role: role,
  user: user,
})
