# Get-Invent
Модуль для удаленного и локального просмотра характеристик физического оборудования: **OS, Mother Board, CPU, RAM, Physical Disk, Logical Disk, Video Card, Network Adapter**.

`Get-Help Get-Invent` \
`Get-Module Get-Invent | fl Description` \
`Get-Invent localhost` по умолчанию \
`Get-Invent -srv server-01` \
`Get-Invent -Full server-01` полный отчет (версия 1.1) \
`Get-Invent -Full -SQL server-01` вывод в базу данных SQLite (версия 1.2)

![Image alt](https://github.com/Lifailon/Get-Invent/blob/rsa/Screen/Example-1.2.jpg)

## Out to database SQLite

* Зависимости: **модуль [MySQLite](https://github.com/jdhitsolutions/MySQLite)**

При создании БД проверяется наличие бд по указанному пути (по умолчанию рабочий стол текущего пользователя и файл с именем **Get-Invent.db**) , если она отсутствует, то создается новая база данных, по такому же принципу проверяются и создаются таблицы для **CPU** (базовый отчет), **Memory**, **PhysicalDisk** и **VideoCard**, и заполняются соответствующими значениями из полного отчета (**-Full**). При последующем наполнении БД информаций с других хостов, необходимо в ручную прописать в к ней путь (ключ **-Path**), в каждой таблице первое значение **Host** присваивается имя компьютера, по которому при фильтрации по нужной модели можно легко индентифицировать имя хоста.

### Для опраса сразу нескольких хостов, и наполнения базы данных используйте слующую конструкцию:

`$HostsList = "$home\desktop\Host-List.txt"` \
`@("server-01","server-02","server-03")` | Out-File $HostsList \
`$Hosts = Get-Content $HostsList` \
`foreach ($srv in $hosts) {` \
`Get-Invent -srv $srv -Full -SQL` \
`}`
