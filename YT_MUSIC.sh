#!/usr/bin/env bash
#
# Script: YT_MUSIC.sh
#
#------------------------------------------------------------------------------------------------
#
#
## Informações do Desenvolvedor
#
#		Desenvolvedor:	Joseano Sousa <joseanodev@gmail.com>
#		Linguagem:	Shell Script
#		Versão:		1.0
#
#
## Descrição
#
#	Bot para Telegram, escrito com a linguagem de programação Shell Script,
#	construído com API não oficial ShellBot e programa linha de comando youtube-dl.
#	Baixa áudios de alta qualidade através de um URL de vídeos ou playlists do YouTube.
#
#
#------------------------------------------------------------------------------------------------

# Importando API
source ShellBot.sh

# Token do bot
bot_token='891968063:AAELsGhINQO4_BCW6DhTTJimerdyxeiKyak'

# Inicializando o bot
ShellBot.init --token "$bot_token" --return map --monitor

while :; do
	# Obtem as atualizações
	ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 30

	# Inicio thread
	(
	# Lista o índice das atualizações
	for id in $(ShellBot.ListUpdates); do

		# Direciona informações do usuário ao arquivo 'users' se o padrão não for encontrado.
		! grep -wqs "${message_chat_id[$id]}" users && echo "${message_chat_id[$id]} ${message_chat_first_name[$id]} ${message_chat_username[$id]:-null}" >> users

		# Executa o bloco se a mensagem é do tipo 'url'
		[[ "${message_entities_type[$id]}" = 'url' ]] && {
			# Cria e altera para o diretório temporário
			path_tmp=$(mktemp -d) && cd $path_tmp
			# Direciona saída com ID(s) para o arquivo 'id'
			youtube-dl --ignore-errors --flat-playlist --get-id "${message_text[$id]}" > id
			# Tratando os itens do arquivo
			for audio_id in $(cat id); do
				# Se o padrão for encontrado execute o bloco
				audio=$(grep -w -- "$audio_id" ~/YT_MUSIC/audios) && {
					# Envia audio por 'file id'
					ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio "${audio##* }"
					# Pule para o próximo ítem
					continue
				}
				# Fazendo download do áudio
				youtube-dl -- "$audio_id"
				# Grava caminho do áudio baixado
				path_audio=@$(find $path_temp -name "*$audio_id.mp3")
				# Executando ação 'upload_audio'
				ShellBot.sendChatAction --chat_id ${message_chat_id[$id]} --action upload_audio
				# Envia audio por caminho local
				ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio "$path_audio"
				# Adiciona informações do audio ao arquivo 'audios' se o padrão não for encontrado
				! grep -wqs -- "$audio_id" ~/YT_MUSIC/audios && echo "$audio_id ${return[audio_file_id]}" >> ~/YT_MUSIC/audios
			done
			# Apaga diretório temporário e quebra o loop
			rm -rf $path_tmp && break
		}

		case "${message_text[id]}" in
			'/start')
				message_text="Olá, *${message_chat_first_name[$id]}*!\n\n"
				message_text+='Me envie um *URL* de um vídeo ou playlist do YouTube, '
				message_text+='você pode utilizar o `@vid` para pesquisar um video ou compartilhar comigo direto do YouTube.\n\n'
				message_text+='Com dúvidas?\nAssista ao /tutorial'
				ShellBot.sendChatAction --chat_id ${message_chat_id[$id]} --action typing
				ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$message_text" --parse_mode markdown
			;;
			'/tutorial')
				ShellBot.sendChatAction --chat_id ${message_chat_id[$id]} --action upload_video
				ShellBot.sendVideo --chat_id ${message_chat_id[$id]} --video BAADAQADgAAD82AJRkV4pEe8iQ9DFgQ
			;;
			*)
				ShellBot.sendChatAction --chat_id ${message_chat_id[$id]} --action typing
				ShellBot.sendMessage --chat_id ${message_chat_id[$id]}  --text '*Erro:* comando inválido!' --parse_mode markdown
			;;
		esac

	done
	) & # Utilize a thread se deseja que o bot responda a várias requisições simultâneas
done
# FIM
ize a thread se deseja que o bot responda a várias requisições simultâneas
done
# FIM
