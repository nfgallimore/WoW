if GetLocale() ~= "esMX" and GetLocale() ~= "esES" then return; end

LocalizationES = setmetatable({
	['SlashCommand'] = '/aj',
	['SettingsTitle'] = 'Ayudante de JcJ',
	['WarsongGulch'] = 'Garganta Grito de Guerro',
	['ArathiBasin'] = 'Cuenca de Arathi',
	['AlteracValley'] = 'Valle de Alterac',
	['EyeOfTheStorm'] = 'Ojo de la Tormenta',
	['StrandOfTheAncients'] = 'Playa de los Ancestros',
	['IsleOfConquest'] = 'Isla de la Conquista',
	['TwinPeaks'] = 'Cumbres Gemelas',
	['BattleForGilneas'] = 'La Batalla por Gilneas',
	['WarsongGulchMinuteWarning'] = 'La batalla comienza en 1 minuto.',
	['ArathiBasinMinuteWarning'] = 'La batalla comenzará en 1 minuto.',
	['AlteracValleyMinuteWarning'] = '1 minuto para que dé comienzo la batalla por el Valle de Alterac.',
	['EyeOfTheStormMinuteWarning'] = '¡La batalla comienza en un minuto!',
	['StrandOfTheAncientsMinuteWarning'] = 'The battle for the Strand of the Ancients begins in 1 minute.',
	['IsleOfConquestMinuteWarning'] = 'La batalla comenzará en 60 segundos.',
	['TwinPeaksMinuteWarning'] = 'La batalla comienza en 1 minuto.',
	['BattleForGilneasMinuteWarning'] = 'La batalla comenzará en 1 minuto.',
	['AnnounceSelf'] = 'Pista de los jugadores ausentes y el informe a si mismo',
	['AnnounceRaid'] = 'Pista de los jugadores ausentes y el informe a su banda',
	['Achievement'] = 'Pista logros incompleta, mientras que en los campos de batalla',
	['PrimarySpec'] = 'Avisa si colas para la batalla en la primera especificacion',
	['SecondarySpec'] = 'Avisa si colas para la batalla en la segunda especificacion',
	['WrongSpec'] = 'Usted no esta en la especificacion correcta para JcJ',
	['GearTrack'] = 'Avisa si colas para la batalla sin armadura para JCJ',
	['WrongGear'] = 'Usted no esta usando la armadura correcta para JCJ',
	['Report'] = ' fue reportado ausente.',
	['Check'] = 'AUS informe: ',
	['Reported'] = ' Reporto',
	['Invalid'] = 'Comando no valido',
	['Version'] = 'Version: ',
	['Loaded'] = 'Ayudante de JcJ cargado, tipo /aj para el panel de control.',
	['HelpUs'] = 'Si cualquiera de las artes se recomienda no coincidentes, mal escrito, no existe o no se borra de la lista despues de que lo compro, o si vas a encontrar falsos positivos con el seguimiento AUS, deja un comentario en nuestra pagina en www.curse.com.',
	['TooLow'] = 'Usted debe llegar a nivel 85 para utilizar la evaluacion armadura.',
	['NoTalent'] = 'Debe seleccionar un árbol de talentos para utilizar la evaluación armadura.',
	['DesignedBy'] = 'Disenado por Speedbumps (Garrosh-US) y Tawnee (Exodar-US)',
	['OldVersion'] = 'Su version del ayudante de JcJ no esta actualizado.',
	['NewVersion'] = ' esta disponible en www.curse.com',
	['Help'] = 'visita www.curse.com ayuda',
	['Avatar'] = '<Ayudante JcJ> ',
	['GearEvaluation'] = 'Evaluacion Armadura',
	['Options'] = 'Opciones',
	['GoodJob'] = 'Usted tiene la mejor armadura disponibles esta temporada.',
	['ShamanHit'] = 'Puede que tenga que reforjar algunos articulos para alcanzar el limite de indice de golpe.',
	['PriestHit'] = 'Se necesitan 2 puntos en el talento "Fe Distorsionada" para alcanzar el límite de índice de golpe.',
	['PaladinHit'] = 'Se necesitan 2 puntos en el talento "Sentencias Iluminadas" para alcanzar el límite de índice de golpe.',
	['DruidHit'] = 'Se necesitan 2 puntos en el talento "Equilibrio de Poder" para alcanzar el límite de índice de golpe.',
	['YouAre'] = 'Usted esta ',
	['LowSpen'] = ' puntos por debajo del limite de penetracion de hechizos.',
	['LowExp'] = ' puntos por debajo del limite de pericia.',
	['LowHit'] = ' puntos por debajo del limite de indice de golpe.',
	['Crafted'] = '(Fabricado)',
	['Honor'] = 'Honor',
	['Conquest'] = 'Conquista',
	['Good'] = 'Bueno: ',
	['Better'] = 'Mejor: ',
	['Best'] = 'El Mejor: ',
	['UnrecognizedItem'] = 'Senalar un error en la pagina curse.com: No hay traduccion en espanol disponible para ',
	},
	{
	__index = function(self, key)
	if debug then ChatFrame3:AddMessage('Please localize: '..tostring(key)) end
		rawset(self, key, key)
		return key
	end }
)




