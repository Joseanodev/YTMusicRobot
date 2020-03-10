#!/usr/bin/env bash
#
#
# Autor:	Joseano Sousa
#
# Versão:	v1.0
#
# Data:		26-11-2019
#
#
# Descrição:	Bot para Telegram feito em Shell.
#		Baixa áudios em alta qualidade de
#		vídeos ou playlists do YouTube.
#
# Uso:		./YT-MUSIC.sh
#

# Importando API - (Passe o caminho de sua API)
source ShellBot.sh

# Token do bot
bot_token="$(<.token)"

# Inicializando o bot
ShellBot.init --token $bot_token --return map --monitor

function hello_bot()
{
	local text
	text="Olá, <b>${message_chat_first_name[$id]}</b>!\n\n"
	text+="Me envie um <b>URL</b> de um vídeo ou playlist do YouTube. "
	text+="Você pode utilizar o <code>@vid</code> para pesquisar um video ou compartilhar comigo direto do YouTube.\n\n"
	[[ ${message_text[$id]} = "/start" ]] && ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$text" --parse_mode html
}

function download_url()
{
	local re_url
	re_url='https?://w*\.?youtu\.?be(\.com)?/(watch\?v=|playlist\?list=)?([a-zA-Z0-9_-]+)'
	if [[ ${message_text[$id]} =~ $re_url ]]; then
		temp_path=$(mktemp -d) && cd $temp_path
		if audio="$(grep ${BASH_REMATCH[3]} $HOME/YT_MUSIC/audios)"; then
			ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio ${audio##* }
		elif [[ ${BASH_REMATCH[2]} = "playlist?list=" ]]; then
			for audio_id in $(youtube-dl --ignore-config --ignore-errors --flat-playlist --get-id $BASH_REMATCH[3]); do
				audio="$(grep ${BASH_REMATCH[3]} $HOME/YT_MUSIC/audios)" && ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio ${audio##* } && continue
				youtube-dl --config-location $HOME/YT_MUSIC/youtube-dl.conf -- $audio_id
				audio_path="$(find $temp_path -name *$audio_id.mp3)"
				[[ -a $audio_path ]] || continue
				ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio @$audio_path
				echo "$audio_id ${return[audio_file_id]}" >> $HOME/YT_MUSIC/audios
			done
			rm -fr $temp_path
		else
			audio_id="${BASH_REMATCH[3]}"
			youtube-dl --config-location $HOME/YT-MUSIC/youtube-dl.conf "$BASH_REMATCH"
			audio_path=@$(find $temp_path -name *$audio_id.mp3)
			ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio $audio_path
			echo "$audio_id ${return[audio_file_id]}" >> $PWD/audios
			rm -fr $temp_path
		fi
	else
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "*Erro:* URL inválida!" --parse_mode markdown
	fi
}

while :; do

	# Obtem as atualizações
	ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 20

	# Lista o índice das atualizações
	for id in $(ShellBot.ListUpdates); do
	# Início thread
	(
	# Verifica e salva informações do usuário.
	grep -sqw ${message_chat_id[$id]} $PWD/users || echo "${message_chat_id[$id]} ${message_chat_first_name[$id]} ${message_chat_username[$id]:-null}" >> $PWD/users


	case ${message_entities_type[id]} in
		url) download_url ;;
		bot_command) hello_bot ;;
	esac
	) & # Utilize a thread se deseja que o bot responda a várias requisições simultâneas
	done
done
