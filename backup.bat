SETLOCAL enabledelayedexpansion

rem Глубина архивации (количество последних архивов, которые должны быть сохранены)
SET ArcDepth=5

rem Путь к каталогу, в который будут складываться резервные копии
SET DirName=backups
rem Путь к каталогу с новым бэкапом (%DATE: =0% %TIME: =0% - замена пробелов в %DATE% и %TIME% на нули)
FOR /f "tokens=1-7 delims=/-:., " %%a IN ("%DATE: =0% %TIME: =0%") do (
	SET NewBkDir=%DirName%\%%c.%%b.%%a_%%d.%%e.%%f.%%g
)
rem Путь к лог-файлу
SET LogFile=%DirName%\%DirName%.LOG

ECHO ***** НАЧАЛО %DATE% %TIME% ***** >> "%LogFile%"

IF NOT EXIST "%DirName%" (
	MD "%DirName%"
	ECHO "%DirName%" - создан >> "%LogFile%"
)

ECHO Создание нового каталога для бэкапа: >> "%LogFile%"
IF NOT EXIST "%NewBkDir%" (
	MD "%NewBkDir%"
	ECHO "%NewBkDir%" - создан >> "%LogFile%"
) ELSE (
	ECHO "%NewBkDir%" - существовал ранее >> "%LogFile%"
)


rem Блок создания дампа БД
SET pg_dump="C:\Program Files\PostgreSQL\15\bin"
SET pathB=backups\
SET dbUser=postgres
SET database=furniture_store

"C:\Program Files\PostgreSQL\15\bin\pg_dump.exe" -U postgres furniture_store > C:\Users\Agafo\WebstormProjects\WebStore\backups\postgres.sql

rem Блок создания новой резервной копии
SET SrcData=backups\postgres.sql
SET ArcName=%NewBkDir%\postgres.rar
ECHO Архивация "%SrcData%" с помощью RAR >> "%LogFile%"

"C:\Program Files\winRAR\Rar.exe" a -m5 -r -ep1 -ri1 -dh -df -ilog"%LogFile%" "%ArcName%" "%SrcData%"

rem Соблюдение глубины архивации (должны остаться только последние %ARCDEPTH% каталогов)
ECHO Удаление старых бэкапов: >> "%LogFile%"
SET Index=0
rem DIR /AD /B /O-D "%DirName%" - получение упорядоченного по дате списка каталогов, начиная с самых новых
FOR /f "tokens=1" %%i IN ('DIR /AD /B /O-D "%DirName%"') DO (
	rem Первые %ArcDepth% архивов пропускаем, остальные удаляем
	SET /a Index+=1
	IF !Index! LEQ %ArcDepth% (
		echo "%DirName%\%%i" - оставлен >> "%LogFile%"
	) else (
		RMDIR /S/Q "%DirName%\%%i"
		echo "%DirName%\%%i" - удален >> "%LogFile%"
	)
)

pg_dump postgres > C:\Users\Agafo\WebstormProjects\WebStore\backups\2023.10.07_14.09.22.23\postgres.dump
ECHO ***** КОНЕЦ %DATE% %TIME%  ***** >> "%LogFile%"
ECHO. >> "%LogFile%"
ECHO. >> "%LogFile%"