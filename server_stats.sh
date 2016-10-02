#!/bin/bash

#El sh llamado old es la version sin añadir o cambiar nada igual esos comandos muestran valores mejores --> http://community.thingspeak.com/2014/05/official-tutorial-monitoring-linux-server-statistics/

# install necessary files:
# sudo apt-get install bc

# make this file executable:
# chmod +x server_stats.sh

# add to crontab (command: crontab -e)
# * * * * * /path/to/server_stats.sh

# thingspeak api key for channel that data will be logged to
api_key='5D906ULWQAMQY3U2'

#LA CPU ESTA MAL
#CPU Obtiene el resto de 100 menos el % usado de la cpu para procesos inactivos,es decir cpu libre.
	cpu_en_usoReal=`top -b -n2 -p 1 | fgrep "Cpu(s)" | tail -1 \
	| tr -s ' ' | cut -f2 -d' ' | cut -f1 -d'%'`
	cpu_en_uso=$(echo $cpu_en_usoReal | cut -d '.' -f 1)
	
#RAM % de memoria RAM usada
	#Memoria RAM Libre 
		used_mem=`free -m | tr -s ' ' | grep Mem | cut -f3 -d' '` 
	#Memoria Total del Sistema
		total_mem=`free -m | tr -s ' ' | grep Mem | cut -f2 -d' '` 
		used_mem_percentReal=`echo "scale=2;($used_mem*100)/$total_mem" | bc`		
		used_mem_percent=$(echo $used_mem_percentReal | cut -d '.' -f 1)

#DISCO % de Disco usado
	#Por si quieres aqui hay un ejemplo para hacerlo en bucle para mas disco -->   http://sobrebits.com/script-bash-para-monitorizar-el-espacio-en-gnulinux/
	used_disk_percent=`df -H | grep /dev/sda1 | expand | tr -s " " | cut -d " " -f5 | cut -d "%" -f1`	
	
#Temperatura en Cº de la raspberry	
	temperaturaReal=`/opt/vc/bin/vcgencmd measure_temp | cut -d = -f 2`
	temperatura=$(echo $temperaturaReal | cut -d '.' -f 1)


	
	
limiteCPU=1
limiteRAM=85
limiteDisco=80
limiteTemperatura=60

if [ ! -f /home/pi/scripts/estadisticasServidor.txt ]
	then
		#CPU,RAM,Disco;Temperatura
		echo 0000 > /home/pi/scripts/estadisticasServidor.txt			
fi

read aux < /home/pi/scripts/estadisticasServidor.txt

  avisadoCPU=${aux:0:1}
  avisadoRAM=${aux:1:1}
  avisadoDisco=${aux:2:1}
  avisadoTemperatura=${aux:3:1}

	
#CPU	
	if [ $cpu_en_uso -ge $limiteCPU ] && [ $avisadoCPU = 0 ]
		then
			echo "Alerta!!!, El uso de la CPU ha superado el umbral de $avisadoCPU %, se situa en: $cpu_en_uso  %"   | mail -s "Alerta,Uso de CPU $cpu_en_uso %" enriquehormillaaragon@gmail.com
			#echo  1000 > /home/pi/estadisticasServidor.txt
			
			avisadoCPU=1
	fi	
	if [ $cpu_en_uso -ge $limiteCPU ] && [ $avisadoCPU = 1 ]
		then
			echo "Corregido!!!,El uso de la CPU  ha vuelto a valores normales, se situa en: $cpu_en_uso  %"  | mail -s "Corregida,Uso de CPU $cpu_en_uso %" enriquehormillaaragon@gmail.com
			#echo  > /home/pi/estadisticasServidor.txt				
			avisadoCPU=0
	fi
	
#RAM	
	if [ $used_mem_percent -ge $limiteRAM ] && [ $avisadoRAM = 0 ]
		then
			echo "Alerta!!!, El uso de la RAM ha superado el umbral de $avisadoRAM %, se situa en: $used_mem_percent  %"   | mail -s "Alerta,Uso de RAM $used_mem_percent %" enriquehormillaaragon@gmail.com
			#echo  1000 > /home/pi/estadisticasServidor.txt
			avisadoRAM=1
	fi	
	if [ $used_mem_percent -lt $limiteRAM ] && [ $avisadoRAM = 1 ]
		then
			echo "Corregido!!!,El uso de la RAM ha vuelto a valores normales, se situa en: $used_mem_percent  %"  | mail -s "Corregida,Uso de RAM $used_mem_percent %" enriquehormillaaragon@gmail.com
			#echo  > /home/pi/estadisticasServidor.txt
			avisadoRAM=0
	fi

#Disco	
	if [ $used_disk_percent -ge $limiteDisco ] && [ $avisadoDisco = 0 ]
		then
			echo "Alerta!!!, El uso del disco duro ha superado el umbral de $avisadoDisco %, se situa en: $used_disk_percent  %"   | mail -s "Alerta,Uso del disco duro $used_disk_percent %" enriquehormillaaragon@gmail.com
			#echo  1000 > /home/pi/estadisticasServidor.txt
			avisadoDisco=1
	fi	
	if [ $used_disk_percent -lt $limiteDisco ] && [ $avisadoDisco = 1 ]
		then
			echo "Corregido!!!,El uso del disco duro ha vuelto a valores normales, se situa en: $used_disk_percent  %"  | mail -s "Corregida,Uso del disco duro $used_disk_percent %" enriquehormillaaragon@gmail.com
			#echo  > /home/pi/estadisticasServidor.txt
			avisadoDisco=0
	fi	

#Temperatura	
	if [ $temperatura -ge $limiteTemperatura ] && [ $avisadoTemperatura = 0 ]
		then
			echo "Alerta!!!, La temperatura ha superado el umbral de $avisadoTemperatura C, se situa en: $temperatura C"   | mail -s "Alerta, La temperatura esta ha $temperatura C" enriquehormillaaragon@gmail.com
			#echo  1000 > /home/pi/estadisticasServidor.txt
			avisadoTemperatura=1
	fi	
	if [ $temperatura -lt $limiteTemperatura ] && [ $avisadoTemperatura = 1 ]
		then
			echo "Corregido!!!, La temperatura esta ha vuelto a valores normales, se situa en: $temperatura  %"  | mail -s "Corregida,La temperatura esta ha $temperatura C" enriquehormillaaragon@gmail.com
			#echo  > /home/pi/estadisticasServidor.txt
			avisadoTemperatura=0
	fi		

auxSalida=$avisadoCPU$avisadoRAM$avisadoDisco$avisadoTemperatura
#echo $auxSalida
echo $auxSalida > /home/pi/scripts/estadisticasServidor.txt	

# post the data to thingspeak
curl -k --data \
"api_key=$api_key&field1=$cpu_en_usoReal&field2=$used_mem_\
percentReal&field3=$used_disk_percent&field4=$temperaturaReal" https://api.thingspeak.com/update

