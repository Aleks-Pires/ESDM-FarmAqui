@echo off
setlocal
cd /d "%~dp0.."

echo ==============================================
echo FarmaAqui - publicar branches no GitHub
echo ==============================================
echo.
set /p REPO_URL=Paste a URL do repositorio vazio do GitHub: 

if "%REPO_URL%"=="" (
  echo URL nao informada.
  pause
  exit /b 1
)

git remote remove origin >nul 2>nul
git remote add origin "%REPO_URL%"

 echo.
echo Enviando branch main...
git push -u origin main
if errorlevel 1 goto erro

 echo.
echo Enviando branch feat/autenticacao-solid...
git push -u origin feat/autenticacao-solid
if errorlevel 1 goto erro

 echo.
echo Pronto. No GitHub, abra uma Pull Request de:
echo feat/autenticacao-solid  -^>  main
echo.
pause
exit /b 0

:erro
echo.
echo O push falhou. Confira se o Git esta instalado e se voce esta autenticado no GitHub.
pause
exit /b 1
