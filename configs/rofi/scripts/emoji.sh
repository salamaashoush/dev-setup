#!/usr/bin/env bash

# Rofi Emoji Picker
# Pick emojis and copy to clipboard

# Emoji data (selection of commonly used emojis)
EMOJIS="😀 Grinning Face
😃 Grinning Face with Big Eyes
😄 Grinning Face with Smiling Eyes
😁 Beaming Face with Smiling Eyes
😆 Grinning Squinting Face
😅 Grinning Face with Sweat
🤣 Rolling on the Floor Laughing
😂 Face with Tears of Joy
🙂 Slightly Smiling Face
😉 Winking Face
😊 Smiling Face with Smiling Eyes
😇 Smiling Face with Halo
🥰 Smiling Face with Hearts
😍 Smiling Face with Heart-Eyes
😘 Face Blowing a Kiss
😗 Kissing Face
😙 Kissing Face with Smiling Eyes
😚 Kissing Face with Closed Eyes
😋 Face Savoring Food
😛 Face with Tongue
😜 Winking Face with Tongue
🤪 Zany Face
😝 Squinting Face with Tongue
🤔 Thinking Face
🤫 Shushing Face
🤗 Hugging Face
🤭 Face with Hand Over Mouth
🤐 Zipper-Mouth Face
😐 Neutral Face
😑 Expressionless Face
😶 Face Without Mouth
😏 Smirking Face
😒 Unamused Face
🙄 Face with Rolling Eyes
😬 Grimacing Face
😮 Face with Open Mouth
😯 Hushed Face
😲 Astonished Face
😳 Flushed Face
🥺 Pleading Face
😦 Frowning Face with Open Mouth
😧 Anguished Face
😨 Fearful Face
😰 Anxious Face with Sweat
😥 Sad but Relieved Face
😢 Crying Face
😭 Loudly Crying Face
😱 Face Screaming in Fear
😖 Confounded Face
😣 Persevering Face
😞 Disappointed Face
😓 Downcast Face with Sweat
😩 Weary Face
😫 Tired Face
😤 Face with Steam From Nose
😡 Pouting Face
😠 Angry Face
🤬 Face with Symbols on Mouth
😈 Smiling Face with Horns
👿 Angry Face with Horns
💀 Skull
☠️ Skull and Crossbones
👻 Ghost
👽 Alien
🤖 Robot
💩 Pile of Poo
😺 Grinning Cat
😸 Grinning Cat with Smiling Eyes
😹 Cat with Tears of Joy
😻 Smiling Cat with Heart-Eyes
😼 Cat with Wry Smile
😽 Kissing Cat
🙀 Weary Cat
😿 Crying Cat
😾 Pouting Cat
❤️ Red Heart
🧡 Orange Heart
💛 Yellow Heart
💚 Green Heart
💙 Blue Heart
💜 Purple Heart
🖤 Black Heart
🤍 White Heart
🤎 Brown Heart
💔 Broken Heart
❣️ Heart Exclamation
💕 Two Hearts
💞 Revolving Hearts
💓 Beating Heart
💗 Growing Heart
💖 Sparkling Heart
💘 Heart with Arrow
💝 Heart with Ribbon
💟 Heart Decoration
☮️ Peace Symbol
✝️ Latin Cross
☪️ Star and Crescent
🕉️ Om
✡️ Star of David
☸️ Wheel of Dharma
☯️ Yin Yang
🔯 Dotted Six-Pointed Star
🕎 Menorah
⚛️ Atom Symbol
🌟 Glowing Star
✨ Sparkles
⭐ Star
🌠 Shooting Star
🌌 Milky Way
☀️ Sun
🌞 Sun with Face
🌝 Full Moon Face
🌛 First Quarter Moon Face
🌜 Last Quarter Moon Face
🌚 New Moon Face
🌕 Full Moon
🌖 Waning Gibbous Moon
🌗 Last Quarter Moon
🌘 Waning Crescent Moon
🌑 New Moon
🌒 Waxing Crescent Moon
🌓 First Quarter Moon
🌔 Waxing Gibbous Moon
🌙 Crescent Moon
🌎 Globe Showing Americas
🌍 Globe Showing Europe-Africa
🌏 Globe Showing Asia-Australia
🪐 Ringed Planet
💫 Dizzy
☄️ Comet
🔥 Fire
💥 Collision
🌈 Rainbow
☁️ Cloud
🌦️ Sun Behind Rain Cloud
⛈️ Cloud with Lightning and Rain
🌩️ Cloud with Lightning
🌨️ Cloud with Snow
☃️ Snowman
⛄ Snowman Without Snow
❄️ Snowflake
🌬️ Wind Face
💨 Dashing Away
🌪️ Tornado
🌫️ Fog
🌊 Water Wave
💧 Droplet
💦 Sweat Droplets
☔ Umbrella with Rain Drops
☂️ Umbrella
🌂 Closed Umbrella
🌀 Cyclone
🦋 Butterfly
🐛 Bug
🐜 Ant
🐝 Honeybee
🐞 Lady Beetle
🦗 Cricket
🕷️ Spider
🕸️ Spider Web
🦂 Scorpion
🦟 Mosquito
🦠 Microbe
🐢 Turtle
🐍 Snake
🦎 Lizard
🦖 T-Rex
🦕 Sauropod
🐙 Octopus
🦑 Squid
🦞 Lobster
🦀 Crab
🦐 Shrimp
🦪 Oyster
🐠 Tropical Fish
🐟 Fish
🐡 Blowfish
🐬 Dolphin
🦈 Shark
🐳 Spouting Whale
🐋 Whale
🐊 Crocodile
🐆 Leopard
🐅 Tiger
🐃 Water Buffalo
🐂 Ox
🐄 Cow
🦌 Deer
🐪 Camel
🐫 Two-Hump Camel
🦒 Giraffe
🦘 Kangaroo
🐘 Elephant
🦏 Rhinoceros
🦛 Hippopotamus
🐭 Mouse Face
🐁 Mouse
🐀 Rat
🐹 Hamster
🐰 Rabbit Face
🐇 Rabbit
🐿️ Chipmunk
🦫 Beaver
🦔 Hedgehog
🦇 Bat
🐻 Bear
🐻‍❄️ Polar Bear
🐨 Koala
🐼 Panda
🦥 Sloth
🦦 Otter
🦨 Skunk
🦡 Badger
🐾 Paw Prints
👍 Thumbs Up
👎 Thumbs Down
👌 OK Hand
✌️ Victory Hand
🤞 Crossed Fingers
🤟 Love-You Gesture
🤘 Sign of the Horns
🤙 Call Me Hand
👈 Backhand Index Pointing Left
👉 Backhand Index Pointing Right
👆 Backhand Index Pointing Up
👇 Backhand Index Pointing Down
☝️ Index Pointing Up
✋ Raised Hand
🤚 Raised Back of Hand
🖐️ Hand with Fingers Splayed
🖖 Vulcan Salute
👋 Waving Hand
🤏 Pinching Hand
✍️ Writing Hand
👏 Clapping Hands
👐 Open Hands
🙌 Raising Hands
🤲 Palms Up Together
🙏 Folded Hands
🤝 Handshake
💪 Flexed Biceps
🦾 Mechanical Arm
🦿 Mechanical Leg
🦵 Leg
🦶 Foot
👂 Ear
🦻 Ear with Hearing Aid
👃 Nose
🧠 Brain
🦷 Tooth
🦴 Bone
👀 Eyes
👁️ Eye
👅 Tongue
👄 Mouth
💋 Kiss Mark
🩸 Drop of Blood
🍕 Pizza
🍔 Hamburger
🍟 French Fries
🌭 Hot Dog
🥪 Sandwich
🌮 Taco
🌯 Burrito
🥗 Green Salad
🍿 Popcorn
🧈 Butter
🥫 Canned Food
🍱 Bento Box
🍘 Rice Cracker
🍙 Rice Ball
🍚 Cooked Rice
🍛 Curry Rice
🍜 Steaming Bowl
🍝 Spaghetti
🍠 Roasted Sweet Potato
🍢 Oden
🍣 Sushi
🍤 Fried Shrimp
🍥 Fish Cake with Swirl
🥮 Moon Cake
🍡 Dango
🥟 Dumpling
🥠 Fortune Cookie
🥡 Takeout Box
🍦 Soft Ice Cream
🍧 Shaved Ice
🍨 Ice Cream
🍩 Doughnut
🍪 Cookie
🎂 Birthday Cake
🍰 Shortcake
🧁 Cupcake
🥧 Pie
🍫 Chocolate Bar
🍬 Candy
🍭 Lollipop
🍮 Custard
🍯 Honey Pot
🍼 Baby Bottle
🥛 Glass of Milk
☕ Hot Beverage
🍵 Teacup Without Handle
🍶 Sake
🍾 Bottle with Popping Cork
🍷 Wine Glass
🍸 Cocktail Glass
🍹 Tropical Drink
🍺 Beer Mug
🍻 Clinking Beer Mugs
🥂 Clinking Glasses
🥃 Tumbler Glass
🥤 Cup with Straw
🧃 Beverage Box
🧉 Mate
🧊 Ice"

# Custom theme
THEME_STR='
window {
    width: 600px;
    height: 60%;
}
listview {
    lines: 15;
    columns: 1;
}
element {
    padding: 8px 12px;
}
element-text {
    font: "CaskaydiaCove Nerd Font 16";
}
'

# Show emoji picker
SELECTED=$(echo "$EMOJIS" | rofi -dmenu -p "Emoji" \
    -theme-str "$THEME_STR" \
    -i \
    -matching fuzzy)

# Exit if nothing selected
[[ -z "$SELECTED" ]] && exit 0

# Extract emoji (first character)
EMOJI="${SELECTED%% *}"

# Copy to clipboard
if [[ "$XDG_SESSION_TYPE" == "wayland" ]] || [[ "$WAYLAND_DISPLAY" != "" ]]; then
    echo -n "$EMOJI" | wl-copy
else
    echo -n "$EMOJI" | xclip -selection clipboard
fi

# Notify
notify-send "Emoji Copied" "$EMOJI copied to clipboard"