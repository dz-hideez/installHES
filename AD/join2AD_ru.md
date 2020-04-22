
Подключение сервера linux к Active Directory

Редактируем файл /etc/hosts добавляем (или редактируем) строку - указываем FQDN для данного хоста (меняем <hostname> на свое имя хоста и <Domain_Name> на имя домена)  :
```shell
127.0.1.1       <hostname>.<Domain_Name>  <hostname>
```
Для корректного подключения к AD необходимо,  чтобы сервер AD был установлен в качестве DNS сервера.
Если в Вашей сети работает DHCP, то как правило, администратор уже назначил
правильные настройки для вашего сервера. 
Посмотреть список текущих dns можно в файле `/etc/resolv.conf` :
```shell
cat /etc/resolv.conf 
```
в качестве nameserver
мы должны увидеть ip нашего сервера AD  

если это не так, можно “вручную” назначить namesrever. 
При использовании dhcp не удасться "напрямую" изменить resolv.conf, поэтому придется выполнить несколько простых действий.

##Ubuntu 18.04

Установим пакет resolvconf
```shell
sudo apt update
sudo apt install resolvconf
sudo systemctl enable resolvconf.service
```
Теперь надо отредактировать файл  `/etc/resolvconf/resolv.conf.d/head`
здесь, надо добавить строку:
```shell
nameserver  <server_ip>
```
и запускаем 
```shell
sudo systemctl start resolvconf.service
```
##Centos 7

Необхдимо добавить строки
```shell
PEERDNS=no
DNS1=<server_ip>
```
в файл /etc/sysconfig/network-scripts/ifcfg-* Здесь  замените ifcfg-* 
именем Вашего сетевого интерфейса
И перегрузить NetworkManager:
```
sudo systemctl restart  NetworkManager
```

чтобы убедиться, что все корректно, проверим еще раз наш resolv.conf
```
cat /etc/resolv.conf
```
Проверяем что имя домена резолвится
Примечание:
на Centos 7 может понадобиться установка пакета bind-utils:
```
sudo yum install bind-utils -y
```

```
nslookup <Domain_Name>
```


Устанавливаем нужные пакеты
```
sudo apt install realmd samba-common-bin samba-libs sssd-tools krb5-user adcli
```
Во время установки kerberos необходимо подтвердить  домен, указать имя сервера     

Проверяем, что наш домен виден в сети:
```
realm discover <Domain_Name>
```
Вводим машину в домен:
```
sudo realm --verbose join <Domain_Name> -U <YourDomainAdmin> --install=/
```
Если не получили никакой ошибки, значит все прошло нормально. Можно зайти на контроллер домена и проверить, появился ли наш linux сервер в домене.

Если сервер Active Directory использует самоподписанные сертификаты,
указываем в файле (добавляем в конец) `/etc/ldap/ldap.conf`  параметр 
```
TLS_REQCERT never
```


Опционально, если нужна непосредственно на linux-сервере авторизация доменных пользователей: 

Редактируем настройки PAM
```
sudo pam-auth-update
```

Для того, чтобы при входе не указывать дополнительно к логину домен, 
можно добавить суффикс по умолчанию. 
Для этого, в файле `/etc/sssd/sssd.conf`, в блоке [sssd] добавляем строку:
```
default_domain_suffix = <Domain_Name>
```

Проверка, что все корректно установилось:

например, получить всех пользователей (придется ввести пароль) :   
```
ldapsearch -x -H "ldaps://<Domain_Name>" -D "<YourDomainAdmin>@<Domain_Name>" -W  -b "dc=<dc>,dc=<dc>, ..." "object
Category=person" name
```
Например, для домена hideez.example.com и администратора с именем administrator строка поиска будет выглядеть так
```
ldapsearch -x -H "ldaps://hideez.example.com" -W -D "administrator@hideez.example.com" -b "dc=hideez,dc=example,dc=com"  "object
Category=person" name
```
В случае ошибки, можно добавить ключ -d1 и внимательно,  посмотреть на описание ошибки.
