location = Location.create!({
  code: 'code',
  url: 'https://code.digitalenergy.online',
  state: 'active',
})
location.sync_images!
