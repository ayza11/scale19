# Работа с сервисом Key Management Service

### Входные данные
* Имеется существующее облако с проставленным alpha-флагом `Yandex Key Management Service`
* Текущий пользователь обладает ролью `owner` или `editor` в облаке из предыдущего пункта
* Пользователь скачал yc cli и выполнил команду `yc init`
* `brew install jq`

### Подготовка окружения
* Зайдите в консоль Яндекс.Облака https://console.cloud.yandex.ru
* Зайдите существующее облако с проставленным alpha-флагом `Yandex Key Management Service`
* Cоздайте новый каталог, зайдите в созданный каталог

### Создание ключа симметричного шифрования
* Перейдите на главную страницу сервиса Key Management Service
* Создайте новый ключ шифрования с параметрами
  * Имя: myFirstKey (или любое другое)
  * Алгоритм: AES_256
  * Период ротации: нет
  * Остальные параметры оставьте по умолчанию, либо измените по своему усмотрению
* Убедитесь, что у вновь созданного ключа автоматически появился первая версия ключа
* Скопируйте id созданного ключа нажав на иконку "Copy" (далее в описании возьмём id равным `fve71roc3v3v1o7fee00`)

### Работа c KMS encrypt/decrypt API
* Скачайте файлы [kms-encrypt.sh](./kms-encrypt.sh),
  [kms-decrypt.sh](./kms-decrypt.sh), [kms-client.sh](./kms-client.sh) и сохраните их на локальный диск рабочей станции. Это скрипты, которые взаимодействуют KMS data plane API по HTTP.
* Откройте terminal, перейдите в каталог с сохранёнными файлами
* Придумайте какой-то секретный текст, например: "Атакуем на рассвете"
* Для шифрования данного текста на вашем ключе KMS, выполните следующие команды:
```
echo "Атакуем на рассвете" > plaintext.txt
./kms-encrypt.sh fve71roc3v3v1o7fee00 "foo=bar" `cat plaintext.txt | base64` > ciphertext.txt
```
* Замечания:
  * Вместо id `fve71roc3v3v1o7fee00` нужно поставить свой id ключа, получечнного в разделе "Создание ключа симметричного шифрования"
  * Фраза `foo=bar` является [Additional Authenticated Data](https://cloud.google.com/kms/docs/additional-authenticated-data) для алгоритма шифрования AES GCM. Это фраза не является секретной, но для расшифрования шифротекста фразу надо передать на вход алгоритма в том же неизменном виде, в каком она была передана алгоритму шифрования
  * Длина plaintext для операций c KMS ecnrypt/decrypt API не должна превышать 32K. Для шифрования данных большего объёма рекомендуется применять схему [envelope encryption](https://cloud.google.com/kms/docs/envelope-encryption) 
* Изучаем содержимое файла `ciphertext.txt`, в нём содержится шифротекст в кодировке BASE64. В файле должно располагаться что-то вроде такого: `AAAAAAAAABRmdmVob29zdGt2M3FidWhpNTZsZgAAAAzXpgRC6vIcqrGaYMQAAAAbattM/9piFG8qUMed0GTgiG1OJRIJaHI1Nraw235mUCC90ISZQldXsFYugQ==`
* Для расшифрования шифротекста выполняем следующие команды:
```
./kms-decrypt.sh fve71roc3v3v1o7fee00 "foo=bar" `cat ciphertext.txt` | base64 --decode
Атакуем на рассвете
```
* Ура! Мы корректно расшифровали наш шифротекст при помощи ключа KMS
