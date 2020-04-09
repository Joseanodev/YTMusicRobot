#!/usr/bin/env bash
#
#
# Autor:	Joseano Sousa
#
# Versão:	v1.6
#
# Data:		23-03-2020
#
#
# Descrição:	Bot para Telegram feito em Shell.
#		Baixa áudios em alta qualidade de
#		vídeos ou playlists do YouTube.
#
# Uso:		./yt-music.sh
#

# Importando API
source ShellBot.sh

# Token do bot
bot_token=$(<.token)

# Inicializando o bot
ShellBot.init --token "$bot_token" --return map --monitor --flush

function get_user_info()
{
	# Verifica e salva informações do usuário.
	grep -sqw ${message_from_id[$id]} users || echo "${message_from_id[$id]} ${message_from_first_name[$id]} ${message_from_username[$id]:-null}" >> users
}

function download_url()
{
	local re_url='https?://w*\.?youtu\.?be(\.com)?/(watch\?v=|playlist\?list=)?([a-zA-Z0-9_-]+)' # Padrão a ser condicionado
	if [[ ${message_text[$id]} =~ $re_url ]]; then
		temp_path=$(mktemp -d) && cd $temp_path
		if audio="$(grep -- ${BASH_REMATCH[3]} $OLDPWD/audios)"; then
			ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio ${audio##* } --reply_to_message_id ${message_message_id[$id]}
		elif [[ ${BASH_REMATCH[2]} = "playlist?list=" ]]; then
			for audio_id in $(youtube-dl --ignore-config --ignore-errors --flat-playlist --get-id -- $BASH_REMATCH[3]); do
				audio="$(grep -- $audio_id $HOME/YTMusicRobot/audios)" && ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio ${audio##* } --reply_to_message_id ${message_message_id[$id]} && continue
				youtube-dl --config-location $OLDPWD/youtube-dl.conf -- $audio_id
				audio_path=$(find $temp_path -name *$audio_id.mp3)
				[[ -a $audio_path ]] || continue
				ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio @$audio_path --reply_to_message_id ${message_message_id[$id]}
				echo "$audio_id ${return[audio_file_id]}" >> $OLDPWD/audios
			done
			rm -fr $temp_path
		else
			audio_id="${BASH_REMATCH[3]}"
			youtube-dl --config-location $OLDPWD/youtube-dl.conf "$BASH_REMATCH"
			audio_path=@$(find $temp_path -name *$audio_id.mp3)
			ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio "$audio_path" --reply_to_message_id ${message_message_id[$id]}
			echo "$audio_id ${return[audio_file_id]}" >> $OLDPWD/audios
			rm -fr $temp_path
		fi
	fi
}

# Definir regras de mensagens
text='Olá, *${message_from_first_name}*!\n\nMe envie um *URL* de um vídeo ou playlist do YouTube. Você pode utilizar o `@vid` para pesquisar um video ou compartilhar comigo direto do YouTube.'
ShellBot.setMessageRules --name "bem_vindo" --action get_user_info --command "/start" --chat_type "private|group|supergroup" --bot_reply_message "$text" --bot_parse_mode markdown --bot_action typing
ShellBot.setMessageRules --name "url_de_download" --action download_url --text 'https?://w*\.?youtu\.?be(\.com)?/(watch\?v=|playlist\?list=)?[a-zA-Z0-9_-]+' --chat_type "private|group|supergroup"

while :; do

	# Obtem as atualizações
	ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 20

	# Lista o índice das atualizações
	for id in $(ShellBot.ListUpdates); do
		# Início thread
		(

		# Gerenciar regras
		ShellBot.manageRules --update_id $id

		) & # Utilize a thread se deseja que o bot responda a várias requisições simultâneas
	done
done
