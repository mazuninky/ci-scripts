#!/bin/bash

#####################
## Telegram notify ##
#####################
# Tool for sending information to telegram channel. For example about successful build
#
# Requirements:
# * curl
#
# Usage:
#  $ ./telegram-notify botToken chatId text
# * botToken: Api token which gave Bot Father
# * chatId: ID of chat to send message to
# * text: Message to send
# Example:
#  $ ./telegram-notify $BOT_TOKEN $CHAT_ID "Successful build"

URL="https://api.telegram.org/bot$1/sendMessage"

curl -s --max-time 10 -d "chat_id=$2&disable_web_page_preview=1&text=$3" "$URL" >/dev/null
