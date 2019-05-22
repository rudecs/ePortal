puts "Seeds started #{Time.now}"

# Product.create!({
#   name_ru: 'Example Product',
#   type: 'example',
#   state: 'active',
#   handler_api: 'Handlers::Example::API',
#   handler_price: File.open(Rails.root.join('handler_price.js')).read,
# })

Product.create!({
  name_ru: 'Облачное пространство',
  name_en: 'Cloud space',
  description_ru: 'Создайте личный защищенный сетевой сегмент, чтобы разместить в нем виртуальные серверы.',
  description_en: 'Create your private protected network segment to place your virtual servers there.',
  additional_description_ru: 'Облачное пространство – это безопасный сетевой сегмент, в котором работают ваши виртуальные серверы. Вы можете создавать несколько таких пространств и распределять по ним виртутальные мощности в соответствии с текущими потребностями',
  additional_description_en: 'Cloud space is a private secure network segment where your servers are attached. You can create several such cloud spaces and distribute resources between them according to your changing needs.',
  type: 'vdc',
  state: 'active',
  handler_api: '::Handler::VDC',
  handler_price: File.open(Rails.root.join('handler_price.js')).read,
})

Product.create!({
  name_ru: 'Виртуальный сервер',
  name_en: 'Virtual server',
  description_ru: 'Легко создайте виртуальный сервер и меняйте его конфигурацию «на лету».',
  description_en: 'Create your own virtual server and upgrade it “on the fly” as needed.',
  additional_description_ru: '«Ваш персональный компьютер, который работает в облаке и доступен вам везде, где есть интернет. Его можно апргрейдить одним нажатием клавиши.',
  additional_description_en: 'Your personal server, which runs in cloud and available to your from anywhere on the Internet. You can easily upgrade it with a few clicks.',
  type: 'vm',
  state: 'active',
  handler_api: '::Handler::VM',
  handler_price: File.open(Rails.root.join('handler_price.js')).read,
})

puts "Seeds completed #{Time.now}"
