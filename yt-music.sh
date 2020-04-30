#!/usr/bin/env bash
#
#
# Author:		Joseano Sousa
#
# Version:		v1.7
#
# Date:			01:50 30 de abr de 2020
#
#
# Description:		Bot para Telegram feito em Shell.
#			Baixa áudios em alta qualidade de
#			vídeos ou playlists do YouTube.
#
# Usage:		./yt-music.sh
#

# Importando API
source ShellBot.sh

# Verificador e validador de token
until [[ -r .token ]]; do
	read -p "Digite seu token: "
	validate_token=$(curl --silent https://api.telegram.org/bot$REPLY/getMe | jq '.ok')
	if $validate_token; then
		echo "$REPLY" > .token
	else
		echo "Erro: digite um token válido." 1>&2
	fi
done

# Token do bot
bot_token=$(<.token)

# Inicializando o bot
ShellBot.init --token "$bot_token" --return map --monitor --flush


# Bem-vindo(a)
function welcome()
{
	# Verifica e salva informações do usuário.
	grep -sqw ${message_from_id[$id]} users || echo "${message_from_id[$id]} ${message_from_first_name[$id]} ${message_from_username[$id]:-null}" >> users
	
	# Mensagem de boas-vindas.
	local text="Olá, *${message_from_first_name[$id]}*!\n\nMe envie um *URL* de um vídeo ou playlist do YouTube. Você pode utilizar o \`@vid\` para pesquisar um video ou compartilhar comigo direto do YouTube."
	ShellBot.sendChatAction --chat_id ${message_chat_id[$id]} --action typing
	ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$text" --parse_mode markdown
}

# Baixando URL
function download_url()
{
	youtube-dl --config-location $OLDPWD/youtube-dl.conf -- ${audio_id:-$url_id}
	audio_path=$(find $temp_path -name *${audio_id:-$url_id}.mp3)
	if [[ -a $audio_path ]]; then
		ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio @$audio_path --reply_to_message_id ${message_message_id[$id]}
		echo "${audio_id:-$url_id} ${return[audio_file_id]}" >> $OLDPWD/audios
	fi
}

# Analisador URL
function url_parser()
{
	local url_regex='https?://(w{3}\.)?youtu\.?be(\.com)?/(watch\?v=|playlist\?list=)?([a-zA-Z0-9_-]+)' # Padrão a ser condicionado
	if [[ ${message_text[$id]} =~ $url_regex ]]; then
		url_id="${BASH_REMATCH[4]}"
		temp_path=$(mktemp -d) && cd $temp_path
		if audio="$(grep -- $url_id $OLDPWD/audios)"; then
			ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio ${audio##* } --reply_to_message_id ${message_message_id[$id]}
		elif [[ ${BASH_REMATCH[3]} != "playlist?list=" ]]; then
			for audio_id in $(youtube-dl --ignore-config --ignore-errors --flat-playlist --get-id -- $url_id); do
				if audio="$(grep -- $audio_id $HOME/YTMusicRobot/audios)"; then
					ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio ${audio##* } --reply_to_message_id ${message_message_id[$id]}
				else
					download_url
				fi
			done
			rm -fr $temp_path
		else
			download_url
			rm -fr $temp_path
		fi
	fi
}

# Definir regras de mensagens
ShellBot.setMessageRules --name "bem_vindo" --action welcome --command "/start" --chat_type "private|group|supergroup" --entitie_type "bot_command"
ShellBot.setMessageRules --name "url_de_download" --action url_parser --text 'https?://(w{3}\.)?youtu\.?be(\.com)?/(watch\?v=|playlist\?list=)?[a-zA-Z0-9_-]+' --chat_type "private|group|supergroup"

while true; do

	# Obtem as atualizações
	ShellBot.getUpdates --offset $(ShellBot.OffsetNext) --limit 100 --timeout 20 --allowed_updates '["message", "inline_query", "chosen_inline_result", "callback_query"]'

	# Lista o índice das atualizações
	for id in $(ShellBot.ListUpdates); do
	# Início thread
	(

	# Gerenciar regras
	ShellBot.manageRules --update_id $id

	) & # Utilize a thread se deseja que o bot responda a várias requisições simultâneas
	done
done
