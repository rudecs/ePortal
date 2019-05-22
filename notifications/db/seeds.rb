puts "=== Start loading seeds (#{Time.now}) ==="

# === TemplatesSets and Templates ===

# TODO: move to some config variable
portal_base_url = ENV['PORTAL_BASE_URL'].presence || 'staging.decs.online'
admin_portal_base_url = [portal_base_url, '8080'].join(':')

[
  {
    key_name: 'blocked_expiration',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Your virtual resources shall be deleted soon',
        content: <<~"HTML".strip_heredoc
          <p>
            Dear Client!
            <br/>
            Your balance is zero or negative, and we had to block your account {{ client.name }} at boodet.online.
            If your balance is still negative in {{ data.days_left }} days, we will have to delete your account and any resources that are associated with it, including all data on your virtual servers
          </p>
          <p>
            <b>Call to action</b>
            <br/>
            Restore positive balance on your account at your earliest convenience to continue using our services, and everything will be online again.
          </p>
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="left" style="margin: 0; background: #2c4edd; border-radius: 0px;">
            <tr>
              <td height="40" style="height: 40px; padding: 2px">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="left" style="margin: 0; background: #ffffff; border-radius: 0px;">
                  <tr>
                    <td width="15" style="width: 15px;">&nbsp;</td>
                    <td style="height: 40px;">
                      <a href="http://#{portal_base_url}/profile?page=payment" style="height: 40px; text-align: center; font-family: Arial, sans-serif; font-size: 18px; line-height: 40px; text-decoration: none; padding: 0; display: block; border-radius: 0px;">
                        <font face="Arial, sans-serif" color="#000000" style="font-size: 18px; line-height: 40px;">
                          <span style="font-family: Arial, sans-serif; color: #000000; font-size: 18px; line-height: 40px; -webkit-text-size-adjust:none;">Recharge&nbsp;balance</span>
                        </font>
                      </a>
                    </td>
                    <td width="15" style="width: 15px;">&nbsp;</td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Ваши серверы скоро удалят',
        content: <<~"HTML".strip_heredoc
          <p>
            Здравствуйте!
            <br/>
            Средства на вашем счете достигли отметки «ноль», ваш аккаунт {{ client.name }} в boodet.online заблокирован. Через {{ data.days_left }} дней мы удалим все виртуальные серверы и облачные пространства, созданные вами в этом аккаунте, а с ними – и все данные, хранящиеся на них.
          </p>
          <p>
            <b>Что делать</b>
            <br/>
            Восстановите положительный баланс прямо сейчас, чтобы продолжить работу, и все boodet.online.
          </p>
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="left" style="margin: 0; background: #2c4edd; border-radius: 0px;">
            <tr>
              <td height="40" style="height: 40px; padding: 2px">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="left" style="margin: 0; background: #ffffff; border-radius: 0px;">
                  <tr>
                    <td width="15" style="width: 15px;">&nbsp;</td>
                    <td style="height: 40px;">
                      <a href="http://#{portal_base_url}/profile?page=payment" style="height: 40px; text-align: center; font-family: Arial, sans-serif; font-size: 18px; line-height: 40px; text-decoration: none; padding: 0; display: block; border-radius: 0px;">
                        <font face="Arial, sans-serif" color="#000000" style="font-size: 18px; line-height: 40px;">
                          <span style="font-family: Arial, sans-serif; color: #000000; font-size: 18px; line-height: 40px; -webkit-text-size-adjust:none;">Пополнить&nbsp;баланс</span>
                        </font>
                      </a>
                    </td>
                    <td width="15" style="width: 15px;">&nbsp;</td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        HTML
      }
    ]
  },
  {
    key_name: 'client_blocked',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Your account has been blocked',
        content: <<~"HTML".strip_heredoc
          <p>
            Dear Client!
            <br/>
            Your balance is zero or negative, and we had to block your account {{ client.name }} at boodet.online.
          </p>
          <p>
            There are two news:
            <br/>
            The bad one: your virtual resources including any virtual servers at boodet.online are suspended.
            <br/>
            The good one: we will keep your data and virtual servers for 28 days as of today so that you have enough time to reactive your account. However, we will be charging you for the storage space consumed by your data.
          </p>
          <p>
            <b>What will happen next</b>
            <br/>
            If your balance is still below zero in 28 days after your account is blocked, we will have to delete your account and any resources that are associated with it, including all data on your virtual servers.
          </p>
          <p>
            <b>Call to action</b>
            <br/>
            Recharge your account for {{ data.recharge_balance_amount }} to restore positive balance as soon as possible, and everything will be online again.
          </p>
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="left" style="margin: 0; background: #2c4edd; border-radius: 0px;">
            <tr>
              <td height="40" style="height: 40px; padding: 2px">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="left" style="margin: 0; background: #ffffff; border-radius: 0px;">
                  <tr>
                    <td width="15" style="width: 15px;">&nbsp;</td>
                    <td style="height: 40px;">
                      <a href="http://#{portal_base_url}/profile?page=payment" style="height: 40px; text-align: center; font-family: Arial, sans-serif; font-size: 18px; line-height: 40px; text-decoration: none; padding: 0; display: block; border-radius: 0px;">
                        <font face="Arial, sans-serif" color="#000000" style="font-size: 18px; line-height: 40px;">
                          <span style="font-family: Arial, sans-serif; color: #000000; font-size: 18px; line-height: 40px; -webkit-text-size-adjust:none;">Recharge&nbsp;balance</span>
                        </font>
                      </a>
                    </td>
                    <td width="15" style="width: 15px;">&nbsp;</td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Ваш аккаунт заблокирован',
        content: <<~"HTML".strip_heredoc
          <p>
            Здравствуйте!
            <br/>
            Средства на вашем счете достигли отметки «ноль», ваш аккаунт {{ client.name }} в boodet.online заблокирован.
          </p>
          <p>
            Две новости
            <br/>
            Плохая: ваши виртуальные серверы boodet.online остановлены. Хорошая: на протяжении 28 дней с момента блокировки мы будем хранить ваши данные на серверах вашего аккаунта, чтобы у вас было достаточно времени возобновить работу, поэтому продолжим списания за использованные вами диски.
          </p>
          <p>
            <b>Что будет дальше</b>
            <br/>
            Если вы не восстановите положительный баланс счета через 28 дней после блокировки аккаунта, мы будем вынуждены удалить ваш аккаунт вместе со всеми созданными серверами/облачными пространствами и данными на них.
          </p>
          <p>
            <b>Что делать</b>
            <br/>
            Пополните баланс прямо сейчас на {{ data.recharge_balance_amount }}, чтобы продолжить работу, и все boodet.online.
          </p>
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="left" style="margin: 0; background: #2c4edd; border-radius: 0px;">
            <tr>
              <td height="40" style="height: 40px; padding: 2px">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="left" style="margin: 0; background: #ffffff; border-radius: 0px;">
                  <tr>
                    <td width="15" style="width: 15px;">&nbsp;</td>
                    <td style="height: 40px;">
                      <a href="http://#{portal_base_url}/profile?page=payment" style="height: 40px; text-align: center; font-family: Arial, sans-serif; font-size: 18px; line-height: 40px; text-decoration: none; padding: 0; display: block; border-radius: 0px;">
                        <font face="Arial, sans-serif" color="#000000" style="font-size: 18px; line-height: 40px;">
                          <span style="font-family: Arial, sans-serif; color: #000000; font-size: 18px; line-height: 40px; -webkit-text-size-adjust:none;">Пополнить&nbsp;баланс</span>
                        </font>
                      </a>
                    </td>
                    <td width="15" style="width: 15px;">&nbsp;</td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        HTML
      }
    ]
  },
  {
    key_name: 'admin_new_cloud_response',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'New cloud response',
        content: <<~"HTML".strip_heredoc
          <p>
            Received new cloud response: {{ data.cloud_response }}.
          </p>
          <p>
            Portal id {{ data.portal_id }}, Cloud id: {{ data.cloud_id }}, Cloud name: {{ data.cloud_name }}.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Получен новый ответ от облака',
        content: <<~"HTML".strip_heredoc
          <p>
            Получен новый ответ от облака: {{ data.cloud_response }}.
          </p>
          <p>
            Portal id: {{ data.portal_id }}, Cloud id: {{ data.cloud_id }}, Cloud name: {{ data.cloud_name }}.
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'admin_email_confirmation',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Verify your email',
        content: <<~"HTML".strip_heredoc
          <p>
            You are almost there. Please verify your email by following this link <a href="http://#{admin_portal_base_url}/confirm_email?token={{ data.email_confirmation_code }}&email={{ data.email }}" target="_blank">http://#{admin_portal_base_url}/confirm_email?token={{ data.email_confirmation_code }}&email={{ data.email }}</a>.
          </p>
          <p>
            If you are not sure what it means, just do not go there.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Подтвердите почтовый адрес',
        content: <<~"HTML".strip_heredoc
          <p>
            Осталось совсем немного. Подтвердите Ваш почтовый адрес, пройдя по ссылке <a href="http://#{admin_portal_base_url}/confirm_email?token={{ data.email_confirmation_code }}&email={{ data.email }}" target="_blank">http://#{admin_portal_base_url}/confirm_email?token={{ data.email_confirmation_code }}&email={{ data.email }}</a>.
          </p>
          <p>
            Если Вы не знаете, о чем речь, не проходите по этой ссылке.
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'admin_password_reset',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Your password reset notification',
        content: <<~"HTML".strip_heredoc
            We have received a requested to reset your password. To continue please follow this link <a href="http://#{admin_portal_base_url}/reset_password?token={{ data.password_reset_code }}" target="_blank">http://#{admin_portal_base_url}/reset_password?token={{ data.password_reset_code }}</a>.
            <br/>
            If you did not request password reset, please contact our support team.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Запрос на изменение пароля',
        content: <<~"HTML".strip_heredoc
          <p>
            Чтобы сбросить пароль, перейдите по этой ссылке <a href="http://#{admin_portal_base_url}/reset_password?token={{ data.password_reset_code }}" target="_blank">http://#{admin_portal_base_url}/reset_password?token={{ data.password_reset_code }}</a>.
            Кнопка Сбросить пароль.
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'customer_review',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Customer feedback',
        content: <<~"HTML".strip_heredoc
          Идентификация отправителя.
          <br />
          Клиент id: {{ data.client_id }}
          <br />
          Пользователь id: {{ data.user_id }}
          <br />
          <br />
          <br />
          Имя: {{ data.name }}
          <br />
          Специальность: {{ data.profession }}
          <br />
          Компания: {{ data.company }}
          <br />
          Задачи: {{ data.tasks }}
          <br />
          Другие IaaS: {{ data.otherIaaS }}
          <br />
          Резервное копирование: {{ data.backup }}
          <br />
          Удобство: {{ data.personalOfficeRating }}
          <br />
          Что было сложно найти: {{ data.featuresHardFind }}
          <br />
          Самое негативное впечатление: {{ data.mostNegativeImpression }}
          <br />
          Самое позитивное впечатление: {{ data.mostPositiveImpression }}
          <br />
          Что исправить: {{ data.whatNeedFix }}
          <br />
          Надежность: {{ data.qualityServiceRating }}
          <br />
          Самое негативное впечатление от виртуальных серверов: {{ data.mostNegativeService }}
          <br />
          Самое позитивное впечатление от виртуальных серверов: {{ data.mostPositiveService }}
          <br />
          Желаемые дополнительные функции или удобства: {{ data.additionalFunctions }}
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Анкета - отзыв пользователя',
        content: <<~"HTML".strip_heredoc
          Идентификация отправителя.
          <br />
          Клиент id: {{ data.client_id }}
          <br />
          Пользователь id: {{ data.user_id }}
          <br />
          <br />
          <br />
          Имя: {{ data.name }}
          <br />
          Специальность: {{ data.profession }}
          <br />
          Компания: {{ data.company }}
          <br />
          Задачи: {{ data.tasks }}
          <br />
          Другие IaaS: {{ data.otherIaaS }}
          <br />
          Резервное копирование: {{ data.backup }}
          <br />
          Удобство: {{ data.personalOfficeRating }}
          <br />
          Что было сложно найти: {{ data.featuresHardFind }}
          <br />
          Самое негативное впечатление: {{ data.mostNegativeImpression }}
          <br />
          Самое позитивное впечатление: {{ data.mostPositiveImpression }}
          <br />
          Что исправить: {{ data.whatNeedFix }}
          <br />
          Надежность: {{ data.qualityServiceRating }}
          <br />
          Самое негативное впечатление от виртуальных серверов: {{ data.mostNegativeService }}
          <br />
          Самое позитивное впечатление от виртуальных серверов: {{ data.mostPositiveService }}
          <br />
          Желаемые дополнительные функции или удобства: {{ data.additionalFunctions }}
        HTML
      }
    ]
  },
  {
    key_name: 'arena_db_order',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Arenadata DB order',
        content: <<~"HTML".strip_heredoc
          <p>Dear client!</p>
          <p>Thank you for your interest in Arenadata DB, a cloud-based analytics database.</p>
          <p>We have accepted your request and will contact you within 24 hours to clarify the details and to prepare your copy of the database.</p>
          <p>
            Sincerely,
            <br />
            ArenaData and DigitalEnergy team
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Заказ Arenadata DB',
        content: <<~"HTML".strip_heredoc
          <p>Уважаемый клиент!</p>
          <p>Спасибо за ваш интерес к облачной аналитической СУБД Arenadata DB.</p>
          <p>Мы приняли вашу заявку и свяжемся с вами в течение суток для уточнения деталей и подгтовки вашего экземпляра базы данных.</p>
          <p>
            С уважением,
            <br />
            Команда ArenaData и DigitalEnergy
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'invitation',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'You\'ve been invited to join client',
        content: <<~"HTML".strip_heredoc
          <p>
            {{ data.sender_name }} invited you as '{{ data.role_name }}' on '{{ data.client_name }}' client.
          </p>
          <p>
            <a href="http://#{portal_base_url}/registration?invitation_token={{ data.invitation_token }}&email={{ user.email }}" target="_blank">Join client</a>.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Приглашение присоединиться к клиенту',
        content: <<~"HTML".strip_heredoc
          <p>
            {{ data.sender_name }} приглашает Вас присоединиться к клиенту '{{ data.client_name }}' в роли '{{ data.role_name }}'.
          </p>
          <p>
            <a href="http://#{portal_base_url}/registration?invitation_token={{ data.invitation_token }}&email={{ user.email }}" target="_blank">Принять приглашение</a>.
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'invitation_with_receiver',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'You\'ve been invited to join client',
        content: <<~"HTML".strip_heredoc
          <p>
            {{ data.sender_name }} invited you as '{{ data.role_name }}' on '{{ data.client_name }}' client.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Приглашение присоединиться к клиенту',
        content: <<~"HTML".strip_heredoc
          <p>
            {{ data.sender_name }} приглашает Вас присоединиться к клиенту '{{ data.client_name }}' в роли '{{ data.role_name }}'.
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'email_confirmation',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Verify your email',
        content: <<~"HTML".strip_heredoc
          <p>
            You are almost there. Please verify your email by following this link <a href="http://#{portal_base_url}/confirm_email?token={{ data.email_confirmation_code }}&email={{ user.email }}" target="_blank">http://#{portal_base_url}/confirm_email?token={{ data.email_confirmation_code }}&email={{ user.email }}</a>.
          </p>
          <p>
            If you are not sure what it means, just do not go there.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Подтвердите почтовый адрес',
        content: <<~"HTML".strip_heredoc
          <p>
            Осталось совсем немного. Подтвердите Ваш почтовый адрес, пройдя по ссылке <a href="http://#{portal_base_url}/confirm_email?token={{ data.email_confirmation_code }}&email={{ user.email }}" target="_blank">http://#{portal_base_url}/confirm_email?token={{ data.email_confirmation_code }}&email={{ user.email }}</a>.
          </p>
          <p>
            Если Вы не знаете, о чем речь, не проходите по этой ссылке.
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'password_reset',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Your password reset notification',
        content: <<~"HTML".strip_heredoc
          <p>
            Dear client!
            We have received a requested to reset your password. To continue please follow this link <a href="http://#{portal_base_url}/reset_password?token={{ data.password_reset_code }}" target="_blank">http://#{portal_base_url}/reset_password?token={{ data.password_reset_code }}</a>.
            <br/>
            If you did not request password reset, please contact our support team.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Запрос на изменение пароля',
        content: <<~"HTML".strip_heredoc
          <p>
            Уважаемый клиент!
            Чтобы сбросить пароль, перейдите по этой ссылке <a href="http://#{portal_base_url}/reset_password?token={{ data.password_reset_code }}" target="_blank">http://#{portal_base_url}/reset_password?token={{ data.password_reset_code }}</a>.
            Кнопка Сбросить пароль.
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'successful_registration',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Welcome to the cloud!',
        content: <<~'HTML'.strip_heredoc
          <p>
            Dear client!
            You have completed your registration at {{ data.portal_instance_name }}. Welcome to the community! Now everything is going to be online!
            <br/>
            Please retain the following information for future reference:
            Client ID: {{ user.id }}
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Приветствуем вас в boodet.online!',
        content: <<~'HTML'.strip_heredoc
          <p>
            Успешная регистрация на портале {{ data.portal_instance_name }}. Добро пожаловать в семью! Теперь все boodet.online!
            <br/>
            Сохраните эту информацию для общения с нашей службой поддержки:
            Код клиента: {{ user.id }}
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'create_product',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Your new product has been created',
        content: <<~'HTML'.strip_heredoc
          <p>
            Dear client!
            <br/>
            Your new product of type {{ data.product_type_name }} identified by the name {{ data.product_instance_name }} has just been created and is ready for use.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Продукт успешно создан',
        content: <<~'HTML'.strip_heredoc
          <p>
            Уважаемый клиент!
            <br/>
            Ваш новый продукт типа {{ data.product_type_name }} под именем {{ data.product_instance_name }} успешно создан и готов к использованию.
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'resize_product',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Your product configuration has been changed',
        content: <<~'HTML'.strip_heredoc
          <p>
            Dear client!
            <br/>
            Configuration of your product {{ data.product_instance_name }} has been changed successfully.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Конфигурация продукта изменена',
        content: <<~'HTML'.strip_heredoc
          <p>
            Уважаемый клиент!
            <br/>
            Конфигурация продукта {{ data.product_instance_name }} успешно изменена.
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'turn_off_product',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Your product entered “stopped” state',
        content: <<~'HTML'.strip_heredoc
          <p>
            Dear client!
            Your product {{ data.product_instance_name }} changed its state to “stopped”.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Продукт выключен',
        content: <<~'HTML'.strip_heredoc
          <p>
            Уважаемый клиент!
            Продукт {{ data.product_instance_name }} переведен в состояние «выключен».
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'delete_product',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Your product has been deleted',
        content: <<~'HTML'.strip_heredoc
          <p>
            Dear client!
            Your product {{ data.product_instance_name }} has just been deleted successfully.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Продукт удален',
        content: <<~'HTML'.strip_heredoc
          <p>
            Уважаемый клиент!
            Продукт {{ data.product_instance_name }} успешно удален.
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'expenses_in_period',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Your expense summary',
        content: <<~'HTML'.strip_heredoc
          <p>
            Dear client!
            Your expense summary for the period {{ data.period }}:
            {{ data.amount }} {{ data.currency }}.
            <br/>
            Please refer to your account for more details.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Ваши расходы',
        content: <<~'HTML'.strip_heredoc
          <p>
            Уважаемый клиент!
            Ваши расходы за период {{ data.period }} составили {{ data.amount }} {{ data.currency }}.
            <br/>
            Детальную информацию по своим расходам вы можете получить в Вашем личном кабинете.
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'successful_payment',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Account recharge notification',
        content: <<~'HTML'.strip_heredoc
          <p>
            You have just recharged your account for {{ data.amount }} {{ data.currency }}.
            <br/>
            Currently your balance is {{ client.current_balance_cents }} {{ client.currency }}.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Пополнение счета',
        content: <<~'HTML'.strip_heredoc
          <p>
            Уважаемый клиент!
            Вы пополнили счет на сумму {{ data.amount }} {{ data.currency }}.
            <br/>
            На вашем счёте сейчас {{ client.current_balance_cents }} {{ client.currency }}.
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'balance_threshold',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Your balance is running low. Your account could be blocked soon.',
        content: <<~'HTML'.strip_heredoc
          <p>
            Dear Client!
            <br/>
            Your balance is running low and once it is at zero level we will have to block your boodet.online account {{ client.name }} in {{ data.days_left }} days.
            <br/>
            If your account is blocked, all your cloud resources will be suspended for maximum 28 days, and you will not be able to access them.
            <br/>
            During this period, we will keep your data, so that you have enough time to reactive your account. However, we will be charging you for the storage space consumed by your data.
            <br/>
            If your balance is still below zero in 28 days after your account is blocked, we will have to delete your account and any resources that are associated with it, including all data on your virtual servers.
          </p>
          <p>
            <b>Call to action</b>
            <br/>
            Recharge your account to restore positive balance as soon as possible, and everything will be online again.
          </p>
          Кнопка «Recharge balance».
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Средства заканчиваются, пополните баланс',
        content: <<~'HTML'.strip_heredoc
          <p>
            Здравствуйте!
            <br/>
            Уже скоро средства на вашем счете достигнут отметки «ноль», и нам придется заблокировать ваш аккаунт {{ client.name }} в boodet.online через {{ data.days_left }} дней.
            <br/>
            В течение 28 дней с даты блокировки ваши виртуальные серверы boodet.online будут остановлены, и вы потеряете доступ к ним.
            <br/>
            Все это время мы будем хранить ваши данные на серверах вашего аккаунта, чтобы у вас было достаточно времени возобновить работу, поэтому продолжим списания за использованные вами диски.
            <br/>
            Если вы не восстановите положительный баланс счета через 28 дней после блокировки аккаунта, мы вынуждены будем удалить ваш аккаунт вместе со всеми созданными серверами и данными на них.
          </p>
          <p>
            <b>Что делать</b>
            <br/>
            Пополните баланс прямо сейчас, чтобы продолжить работу, и все boodet.online.
          </p>
          Кнопка «Пополнить баланс».
        HTML
      }
    ]
  },
  {
    key_name: 'create_ticket',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Support ticket has been created',
        content: <<~'HTML'.strip_heredoc
          <p>
            Dear client!
            We have received your message!
            Our support experts will answer soon.
            <br/>
            In the meantime please retain the following information for your reference:
            Ticket ID {{ data.ticket_id }}
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Ваша заявка принята',
        content: <<~'HTML'.strip_heredoc
          <p>
            Уважаемый клиент!
            Мы зарегистрировали Ваше обращение! Ожидайте ответа наших специалистов.
            <br/>
            Пожалуйста, при общении со службой поддержки по вашему вопросу используйте следующую информацию:
            Номер обращения {{ data.ticket_id }}
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'ticket_response',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Feedback from technical support',
        content: <<~'HTML'.strip_heredoc
          <p>
            Dear client!
            Support team provided feedback to your message.
          </p>
          Click here to view.
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Ответ от техподдержки boodet.online',
        content: <<~'HTML'.strip_heredoc
          <p>
            Уважаемый клиент!
            Вам пришел ответ от службы технической поддержки.
          </p>
          Кнопка Посмотреть ответ.
        HTML
      }
    ]
  },
  {
    key_name: 'bonus_income',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Good news: you have been awarded bonus points',
        content: <<~'HTML'.strip_heredoc
          <p>
            Dear client!
            You have just being awarded {{ data.bonus_amount }} bonus points.
            To start spending bonus points on our products please first convert them to your account balance.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Приятная новость: вы получили бонусы',
        content: <<~'HTML'.strip_heredoc
          <p>
            Вам начислено {{ data.bonus_amount }} баллов.
            Чтобы использовать их для оплаты наших облачных сервисов, конвертируйте их в Вашем личном кабинете.
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'successful_bonus_conversion',
    templates: [
      {
        locale: 'en',
        delivery_method: 'email',
        subject: 'Bonus points converted successfully',
        content: <<~'HTML'.strip_heredoc
          <p>
            Dear client!
            You have just converted {{ data.bonus_amount }} bonus points into {{ data.amount }} {{ data.currency }} on your account.
          </p>
        HTML
      },
      {
        locale: 'ru',
        delivery_method: 'email',
        subject: 'Конвертация бонусов прошла гладко',
        content: <<~'HTML'.strip_heredoc
          <p>
            Уважаемый клиент!
            Вы успешно конвертировали {{ data.bonus_amount }} баллов в {{ data.amount }} {{ data.currency }} на Вашем счете в Личном кабинете.
          </p>
        HTML
      }
    ]
  },
  {
    key_name: 'phone_number_verification',
    templates: [
      {
        locale: 'en',
        delivery_method: 'sms',
        content: 'Phone number verification code: {{ data.phone_confirmation_code }}'
      },
      {
        locale: 'ru',
        delivery_method: 'sms',
        content: 'Код подтверждения номера телефона: {{ data.phone_confirmation_code }}'
      }
    ]
  },
  {
    key_name: 'two_factor_authentication',
    templates: [
      {
        locale: 'en',
        delivery_method: 'sms',
        content: 'Authentication code: {{ data.sms_token }}'
      },
      {
        locale: 'ru',
        delivery_method: 'sms',
        content: 'Код для входа: {{ data.sms_token }}'
      }
    ]
  }
].each do |prms|
  ts = TemplatesSet.find_or_create_by(key_name: prms[:key_name])
  prms[:templates].each do |tmpl|
    ts.templates
      .create_with(content: tmpl[:content])
      .find_or_create_by(locale: tmpl[:locale], delivery_method: tmpl[:delivery_method], subject: tmpl[:subject])
  end
end

puts "=== Loading seeds completed (#{Time.now}) ==="
