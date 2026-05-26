$env:PGPASSWORD = "NikhitaMumbai123*"
$pgPath = "C:\Program Files\PostgreSQL\16\bin\psql.exe"
& $pgPath -U postgres -d omoiservespare_db -f update-vendor-hash.sql
Remove-Item Env:\PGPASSWORD
