#!/bin/bash

# Inicialização
snak=( "3:8" "3:7" "3:6" )

limite=(1 41 1 41)
comida="6:7"
pontos=0
move='0:1'
cursor=1
# Função de renderização
renderizar() {
  ${cursor:+ tput civis}
  ${cursor:+ unset cursor}
  tput clear
  for parte in "${snak[@]}"; do
    tput cup ${parte//:/ }
	echo -en "@"
  done
  tput cup ${comida//:/ }
  echo -en "O"
}

# Função de andar
andar() {
  andar_linha="${move//:*}"
  andar_coluna="${move//*:}"
  posicao_futura="$((${snak[0]//:*}+andar_linha)):$((${snak[0]//*:}+andar_coluna))"
  for anda in "${!snak[@]}"; do
    posicao_atual="${snak[$anda]}"
	snak[$anda]="$posicao_futura"
	posicao_futura="$posicao_atual"
  done
}

# Função de perder
perder() {
  clear
  echo "Você perdeu!"
  echo "Pontos: $pontos"
  tput sgr0
  exit
}

# Função de bater
bater() {
  local ver=1
  for local in 0 1; do
     if [[ ${snak[0]//:*} -eq ${limite[$local]} || ${snak[0]//*:} -eq ${limite[$((local+2))]} ]]; then
	 	perder
	 fi
  done
  
  for corpo in "${snak[@]}"; do
	${ver:+ eval "unset ver; continue;"}
    if [[ ${snak[0]} == $corpo ]]; then
      perder
    fi
  done
}

# Função de comer
comer() {
  if [[ ${snak[0]} == $comida ]]; then
    fim=${#snak[@]}
    almento_linnha=$((${snak[$((fim-1))]//:*} - ${snak[$((fim-2))]//:*}))
    almento_coluna=$((${snak[$((fim-1))]//*:} - ${snak[$((fim-2))]//*:}))
    acrescer_linha=$((${snak[$((fim))]//:*} + 0$almento_linha))
    acrescer_coluna=$((${snak[$((fim))]//:*} + 0$almento_coluna))
    snak[$fim]="$acrescer_linha:$acrescer_coluna"
    ((pontos++))
    unset comida
  fi
}

# Função de gerar comida
comidas() {
  if [[ -z $comida ]]; then
    linha=$(((RANDOM % (${limite[1]} - ${limite[0]} + 1) + ${limite[0]})))
    coluna=$(((RANDOM % (${limite[3]} - ${limite[2]} + 1) + ${limite[2]})))
    comida="$linha:$coluna"
  fi
  for ocupado in "${snak[@]}"; do
     if [[ $comida == $ocupado ]]; then
	    comidas
		break
	 fi
  done
}

# Função de interação com o usuário
interagir() {
  read -n1 -t 0.2 direcao
  case $direcao in
    w) [[ $move != "1:0" ]] && move="-1:0" ;;
    d) [[ $move != "0:-1" ]] && move="0:1" ;;
    a) [[ $move != "0:1" ]] && move="0:-1" ;;
    s) [[ $move != "-1:0" ]] && move="1:0" ;;
  esac
}

# Função principal
mover() {
  while true; do
    interagir
    andar
    bater
    comer
    comidas
    renderizar
  done
}

# Iniciar o jogo
mover
tput sgr0