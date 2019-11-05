# YT_MUSIC Bot v1.0

![Logo YouTube Music](youtube-music-logo.png)

## Nota

Para usufruir o conteúdo deste repositório, precisa-se está familiarizado com as seguintes exigências:

- **[Programa(comando) - youtube-dl](https://github.com/ytdl-org/youtube-dl)**

	O youtube-dl é um programa de linha de comando para baixar vídeos do YouTube.com e mais alguns sites. Requer o interpretador Python, versão 2.6, 2.7 ou 3.2+, e não é específico da plataforma. Ele deve funcionar na sua caixa Unix, no Windows ou no macOS. É liberado para o domínio público, o que significa que você pode modificá-lo, redistribuí-lo ou usá-lo como quiser.

- **[Programação em Shell Script](https://pt.m.wikipedia.org/wiki/Shell_script)**

	Shell script é uma linguagem de script usada em vários sistemas operativos (operacionais), com diferentes dialetos, dependendo do interpretador de comandos utilizado.

- **[API ShellBot](https://github.com/shellscriptx/shellbot)**

	O ShellBot.sh é uma API desenvolvida em shell script que permite a criação de bot's na plataforma Telegram.

## Instruções

- [Sobre YT_MUSIC](#sobre-yt-music)
- [Configuração - youtube-dl](#configuração-youtube-dl)
- [Código-fonte](#código-fonte)
- [Informações do Desenvolvedor](#informações-do-desenvolvedor)

## Sobre YT_MUSIC

**YT_MUSIC** é um bot escrito com a linguagem de programação Shell Script, construído com API não oficial **[ShellBot](https://github.com/shellscriptx/shellbot)** e programa linha de comando **[youtube-dl](https://github.com/ytdl-org/youtube-dl)**.  
Resumindo é um bot para Telegram que baixa áudios MP3 de alta qualidade de vídeos ou playlists do YouTube.

## Configuração - youtube-dl

As configurações do programa **youtube-dl** ficam no diretório `/etc` no arquivo `youtube-dl.conf`, onde contém as opções definida para o YouTube Music.
Você pode personalizar de acordo com sua preferência editando o arquivo `/etc/youtube-dl.conf`.

Para obter as configurações execute:

	sudo wget  https://raw.githubusercontent.com/Joseanodev/YTMusicRobot/master/youtube-dl.conf -O /etc/youtube-dl.conf

## Código-fonte

Baixe o código-fonte deste repositório:

	git clone https://github.com/Joseanodev/YTMusicRobot && cd YTMusicRobot

## Informações do Desenvolvedor

**Versão:** 1.0  
**Desenvolvedor:** Joseano Sousa  
**E-mail:** joseanodev@gmail.com  
**Telegram:** [@joseanodev](https://t.me/joseanodev)