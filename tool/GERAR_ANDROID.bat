@echo off
setlocal
cd /d "%~dp0.."

echo Gerando os arquivos nativos Android do projeto Flutter...
flutter create --platforms=android --org br.edu.ufal --project-name farma_aqui .
if errorlevel 1 goto erro

flutter pub get
if errorlevel 1 goto erro

flutter test
if errorlevel 1 goto erro

echo.
echo Projeto Android gerado e testes executados com sucesso.
pause
exit /b 0

:erro
echo.
echo O processo falhou. Confira se o Flutter esta instalado e disponivel no PATH.
pause
exit /b 1
