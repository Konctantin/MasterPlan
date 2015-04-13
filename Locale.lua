local L, _, T = GetLocale(), ...

-- See http://townlong-yak.com/master-plan/localization
T.L =
L == "deDE" and {
	["*"] = "*",
	["Active Missions (%d)"] = "Aktive Missionen (%d)",
	["Additional mission loot may be delivered via mail."] = "Zusätzliche Missionsbeute kann per Post zugestellt werden.",
	["An additional random ability is unlocked when this follower reaches epic quality."] = "Freigeschaltet wenn dieser Anhänger epische Qualität erreicht.",
	["Available; expires in %s"] = "Zur Verfügung; erlischt in %s",
	["Available Missions (%d)"] = "Verfügbare Missionen (%d)",
	["Can be countered by:"] = "Gekontert von:",
	["Chance of success"] = "Aussicht auf Erfolg",
	["Click to view upgrade options"] = "Klicken um Upgrade Optionen anzuzeigen",
	["Complete All"] = "Alle abschließen",
	["Complete Missions"] = "Missionen abschließen",
	["Complete party"] = "Gruppe vervollständigen",
	["%dh %dm"] = "%dstd %dmin",
	["+%d Inactive (hold ALT to view)"] = "+%d Untätig (halte ALT-Taste zum betrachten)",
	Done = "Fertig",
	["%d%% success chance"] = "%d%% Erfolgschance",
	["Duplicate counters"] = "Doppelt kontern",
	["Epic Ability"] = "Epische Fähigkeit",
	["Expedited mission completion"] = "Beschleunigter Missionsabschluss",
	["Expires in:"] = "Läuft ab in:",
	Failed = "Fehlgeschlagen",
	["Follower experience"] = "Anhängererfahrung",
	["Follower experience per hour"] = "Anhänger EP pro Stunde",
	["Followers activating this trait:"] = "Anhänger die diese Eigenschaft auslösen:",
	["Followers with this trait:"] = "Anhänger mit dieser Eigenschaft:",
	["Follower XP"] = "Anhänger EP",
	["Future Mission #%d"] = "Zukünftige Mission #%d",
	["Garrison resources"] = "Garnisonsressourcen",
	["Group %d"] = "Gruppe %d",
	["Group suggestions will be updated to include the selected follower."] = "Gruppen Vorschläge werden aktualisiert, beim einbeziehen des gewählten Anhängers.",
	Idle = "untätig",
	["Idle (max-level)"] = "untätig (Höchststufe)",
	Ignore = "Ignorieren",
	Ignored = "Ignoriert",
	Instant = "unmittelbar",
	["In Tentative Party"] = "In vorläufiger Gruppe",
	["Last offered: %s ago"] = "Zuletzt abgeschlossen: Vor %s",
	["Mission duration"] = "Missionsdauer",
	["Mission expiration"] = "Mission Ablaufzeit",
	["Mission level"] = "Missionslevel",
	["Mission order:"] = "Missionssortierung:",
	["Missions of Interest"] = "Interessante Missionen",
	["Mitigated threats"] = "Entschärfte Bedrohungen",
	["Potential counters:"] = "Mögliche Konter:",
	Ready = "Bereit",
	["Redundant followers:"] = "Nicht benötigte Anhänger:",
	["Reward: %s XP"] = "Belohnung: %s EP",
	["Right-click to clear all tentative parties."] = "Rechts-Klick um alle vorläufigen Gruppen zu löschen",
	["Select a follower to focus on"] = "Wähle einen Anhänger, den du in den Mittelpunkt stellen möchtest",
	["Send Tentative Parties"] = "Vorläufige Gruppen senden",
	["+%s experience expected"] = "+%s Erfahrung erwartet",
	["%sk"] = "%sk",
	Skipped = "Übersprungen",
	["Start Missions"] = "Missionen starten",
	Success = "Erfolgreich",
	["Success chance"] = "Erfolgschance",
	["Suggested groups"] = "Vorgeschlagene Gruppen",
	["%s XP"] = "%s EP",
	["%s XP gained"] = "%s EP erhalten",
	["%s XP/h"] = "%s EP/h",
	["This follower could counter the following threats:"] = "Dieser Anhänger könnte folgende Gefahren kontern:",
	["Time Horizon"] = "Zeithorizont",
	[ [=[Time until you next expect to be able to interact with garrison missions.

This may affect suggested groups and mission sorting order.]=] ] = [=[Die erwatete Zeit bis du zum nächsten mal mit Garnison Missionen interagieren kannst.

Dies kann die vorgeschlagen Gruppen und Mission-Sortierreihenfolge beeinflussen.]=],
	Unignore = "Einbeziehen",
	["Unique ability rerolls:"] = "Einzigartige Fähigkeit neu würfeln:",
	["View Rewards"] = "Belohnungen ansehen",
	["You have no followers to counter this mechanic."] = "Du hast keine Begleiter, die diese Fähigkeit kontern können.",
	["You have no followers who activate this trait."] = "Du hast keine Anhänger die diese Eigenschaft auslösen.",
	["You have no followers with duplicate counter combinations."] = "Sie haben keine Anhänger mit doppelten Konter Kombinationen.",
	["You have no followers with this trait."] = "Du hast keinen Anhänger mit dieser Eigenschaft.",
	["You have no free bag slots."] = "Du hast keine freien Taschenplätze.",
	["You must restart World of Warcraft after installing this update."] = "Du musst World of Warcraft neustarten nachdem du dieses Update installiert hast.",
} or
L == "esES" and {
	["*"] = "*",
	["Active Missions (%d)"] = "Misiones activas (%d)",
	["Additional mission loot may be delivered via mail."] = "El botín adicional de misiones podría ser enviado vía correo.",
	["An additional random ability is unlocked when this follower reaches epic quality."] = "Una habilidad adicional aleatoria se desbloqueará cuando este seguidor alcance la calidad épica.",
	["Available; expires in %s"] = "Disponible; expira en %s",
	["Available Missions (%d)"] = "Misiones disponibles (%d)",
	["Can be countered by:"] = "Contrarrestado por:",
	["Chance of success"] = "Probabilidad de éxito",
	["Click to view upgrade options"] = "Click para ver opciones de actualización",
	["Complete All"] = "Completar todas",
	["Complete Missions"] = "Completar Misiones",
	["Complete party"] = "Completar Grupo",
	["%dh %dm"] = "%dh %dm",
	["+%d Inactive (hold ALT to view)"] = "+%d Inactivo (mantén ALT para ver)",
	Done = "Listo",
	["%d%% success chance"] = "%d%% probabilidad de éxito",
	["Duplicate counters"] = "Habilidades duplicadas",
	["Epic Ability"] = "Habilidad Épica",
	["Expedited mission completion"] = "Acelerar el completado de misiones",
	["Expires in:"] = "Expira en:",
	Failed = "Fallado",
	["Follower experience"] = "Experiencia de seguidores",
	["Follower experience per hour"] = "Experiencia de seguidor por hora",
	["Followers activating this trait:"] = "Seguidores que activan este rasgo:",
	["Followers with this trait:"] = "Seguidores con este rasgo:",
	["Follower XP"] = "Experiencia de Seguidor",
	["Future Mission #%d"] = "Misión futura  #%d",
	["Garrison resources"] = "Recursos de Ciudadela",
	["Group %d"] = "Grupo %d",
	["Group suggestions will be updated to include the selected follower."] = "Los grupos sugeridos se actualizarán para incluir el seguidor seleccionado.",
	Idle = "Desocupado",
	["Idle (max-level)"] = "Desocupado (nivel-max)",
	Ignore = "Ignorar",
	Ignored = "Ignorado",
	Instant = "Instantáneo",
	["In Tentative Party"] = "En Grupo Tentativo",
	["Last offered: %s ago"] = "Últimos completados: hace %s",
	["Mission duration"] = "Duración de la misión",
	["Mission expiration"] = "Expiración de la Misión",
	["Mission level"] = "Nivel de misión",
	["Mission order:"] = "Orden de misión:",
	["Missions of Interest"] = "Misiones de Interés ",
	["Mitigated threats"] = "Amenazas mitigadas",
	["Potential counters:"] = "Podría contrarrestar:",
	Ready = "Listo",
	["Redundant followers:"] = "Seguidores redundantes:",
	["Reward: %s XP"] = "Recompenza: %s XP",
	["Right-click to clear all tentative parties."] = "Click derecho para borrar todos los grupos tentativos.",
	["Select a follower to focus on"] = "Selecciona un seguidor para centrarte en él",
	["Send Tentative Parties"] = "Enviar Grupos Tentativos",
	["+%s experience expected"] = "+%s experiencia esperada",
	["%sk"] = "%sk",
	Skipped = "Saltada",
	["Start Missions"] = "Comenzar Misiones",
	Success = "Éxito ",
	["Success chance"] = "Probabilidad de éxito",
	["Suggested groups"] = "Grupos Sugeridos",
	["%s XP"] = "%s XP",
	["%s XP gained"] = "%s XP ganada",
	["%s XP/h"] = "%s XP/h",
	["This follower could counter the following threats:"] = "Este seguidor podría contrarrestar estas amenazas:",
	["Time Horizon"] = "Tiempo Previsto",
	[ [=[Time until you next expect to be able to interact with garrison missions.

This may affect suggested groups and mission sorting order.]=] ] = [=[Tiempo hasta la siguiente vez que puedas interactuar con las misiones de la ciudadela.

Esto puede afectar a los grupos sugeridos y el ordenamiento de las misiones.]=],
	Unignore = "Quitar Ignorar",
	["Unique ability rerolls:"] = "Reasignación de habilidades únicas:",
	["View Rewards"] = "Mostrar Recompensas",
	["You have no followers to counter this mechanic."] = "No tienes ningún seguidor que contrarreste esta mecánica.",
	["You have no followers who activate this trait."] = "No tienes seguidores que activen este rasgo.",
	["You have no followers with duplicate counter combinations."] = "No tienes seguidores con combinaciones de habilidades duplicadas.",
	["You have no followers with this trait."] = "No tienes ningún seguidor con este rasgo.",
	["You have no free bag slots."] = "No tienes espacio en las mochilas.",
	["You must restart World of Warcraft after installing this update."] = "Debes reiniciar el juego después de instalar esta actualizción.",
} or
L == "esMX" and {
	["*"] = "*",
	["Active Missions (%d)"] = "Misiones activas (%d)",
	["Additional mission loot may be delivered via mail."] = "Botín adicional de misiones podría ser enviado vía correo.",
	["An additional random ability is unlocked when this follower reaches epic quality."] = "Una facultad adicional es desbloqueada al azar cuando este seguidor alcance calidad épica.",
	["Available; expires in %s"] = "Disponible; expira en %s",
	["Available Missions (%d)"] = "Misiones disponibles (%d)",
	["Can be countered by:"] = "Contrarrestado por:",
	["Chance of success"] = "Probabilidad de éxito",
	["Click to view upgrade options"] = "Click para ver opciones de actualizado",
	["Complete All"] = "Completar todos.",
	["Complete Missions"] = "Completar Misiones",
	["Complete party"] = "Completar Grupo",
	["%dh %dm"] = "%dh %dm",
	["+%d Inactive (hold ALT to view)"] = "+%d Inactivo (presione ALT para ver)",
	Done = "Listo",
	["%d%% success chance"] = "%d%% probabilidad de éxito",
	["Duplicate counters"] = "Facultades duplicadas",
	["Epic Ability"] = "Facultad Épica",
	["Expedited mission completion"] = "Acelerar el completado de misiones",
	["Expires in:"] = "Expira en:",
	Failed = "Fallado",
	["Follower experience"] = "Experiencia de seguidores",
	["Follower experience per hour"] = "Experiencia de seguidor por hora",
	["Followers activating this trait:"] = "Seguidores activando esta característica:",
	["Followers with this trait:"] = "Seguidores con esta característica:",
	["Follower XP"] = "Experiencia de Seguidor",
	["Future Mission #%d"] = "Futura misión #%d",
	["Garrison resources"] = "Recursos de Fortaleza",
	["Group %d"] = "Grupo %d",
	["Group suggestions will be updated to include the selected follower."] = "Las sugerencias de grupo serán actualizadas para incluir el seguidor seleccionado.",
	Idle = "Desocupado",
	["Idle (max-level)"] = "Desocupado (nivel-max)",
	Ignore = "Ignorar",
	Ignored = "Ignorado",
	Instant = "Instantáneo",
	["In Tentative Party"] = "En Grupo Tentativo",
	["Last offered: %s ago"] = "Últimos completados: hace %s",
	["Mission duration"] = "Duración de la misión",
	["Mission expiration"] = "Expiración de la Misión",
	["Mission level"] = "Nivel de misión",
	["Mission order:"] = "Orden de misión:",
	["Missions of Interest"] = "Misiones de interés ",
	["Mitigated threats"] = "Amenazas mitigadas",
	["Potential counters:"] = "Podría contrarrestar:",
	Ready = "Listo",
	["Redundant followers:"] = "Seguidores no utilizados",
	["Reward: %s XP"] = "Recompenza: %s EXP",
	["Right-click to clear all tentative parties."] = "Clic derecho para limpiar todos los grupos tentativos",
	["Select a follower to focus on"] = "Seleccione un seguidor para enfocarse en él",
	["Send Tentative Parties"] = "Enviar grupos tentativos",
	["+%s experience expected"] = "+%s experiencia esperada",
	["%sk"] = "%sk",
	Skipped = "Saltado",
	["Start Missions"] = "Iniciar misiones",
	Success = "Éxito ",
	["Success chance"] = "Probabilidad de éxito",
	["Suggested groups"] = "Grupos Sugeridos",
	["%s XP"] = "%s EXP",
	["%s XP gained"] = "%s EXP ganada",
	["%s XP/h"] = "%s EXP/h",
	["This follower could counter the following threats:"] = "Este seguidor podría contrarrestar las siguientes amenazas:",
	["Time Horizon"] = "Horizonte temporal",
	[ [=[Time until you next expect to be able to interact with garrison missions.

This may affect suggested groups and mission sorting order.]=] ] = [=[Cantidad de tiempo que pasará hasta que puedas interactuar con las misiones de la fortaleza.

Esto puede afectar las sugerencias de grupos y el ordenamiento de las misiones.
]=],
	Unignore = "Quitar Ignorar",
	["Unique ability rerolls:"] = "Probabilidad de combo unico",
	["View Rewards"] = "Mostrar Recompensas",
	["You have no followers to counter this mechanic."] = "No tienes ningún seguidor que contrarreste esta mecánica.",
	["You have no followers who activate this trait."] = "No tienes seguidores que activen esta característica.",
	["You have no followers with duplicate counter combinations."] = "No tienes seguidores con facultades duplicadas",
	["You have no followers with this trait."] = "No tienes ningún seguidor con esta característica,",
	["You have no free bag slots."] = "No tienes espacio en las mochilas.",
	["You must restart World of Warcraft after installing this update."] = "Debes reiniciar el juego después de instalar esta actualizción.",
} or
L == "frFR" and {
	["*"] = "*",
	["Active Missions (%d)"] = "Missions en cours (%d)",
	["Additional mission loot may be delivered via mail."] = "Le butin supplémentaire de mission sera renvoyé par courrier.",
	["An additional random ability is unlocked when this follower reaches epic quality."] = "Déverrouillé quand ce sujet atteint la qualité épique.",
	["Available; expires in %s"] = "Disponible, expire dans %s",
	["Available Missions (%d)"] = "Missions disponibles (%d)",
	["Can be countered by:"] = "Contrecarré par :",
	["Chance of success"] = "chance de réussite",
	["Click to view upgrade options"] = "Cliquer pour voir les options d'amélioration",
	["Complete All"] = "Tout terminer",
	["Complete Missions"] = "Terminer les missions",
	["Complete party"] = "Groupe complet",
	["%dh %dm"] = "%d h %d m ",
	["+%d Inactive (hold ALT to view)"] = "+%d inactif (maintenez ALT pour afficher)",
	Done = "Terminé",
	["%d%% success chance"] = "%d%% chances de succès",
	["Duplicate counters"] = "Contre-attaque en double",
	["Epic Ability"] = "Aptitude épique",
	["Expedited mission completion"] = "Rendre rapidement toutes les missions",
	["Expires in:"] = "Expire dans :",
	Failed = "Échec",
	["Follower experience"] = "expérience de sujets",
	["Follower experience per hour"] = "EXP/heure pour le sujet",
	["Followers activating this trait:"] = "Sujets actifs avec ce profil :",
	["Followers with this trait:"] = "Sujets avec ce profil :",
	["Follower XP"] = "EXP du sujet",
	["Future Mission #%d"] = "Future mission #%d",
	["Garrison resources"] = "ressources de fief",
	["Group %d"] = "Groupe %d",
	["Group suggestions will be updated to include the selected follower."] = "Les suggestions de groupe seront mise à jour pour inclure le sujet sélectionné.",
	Idle = "inactif(s)",
	["Idle (max-level)"] = "inactif(s) (niv maxi)",
	Ignore = "Ignorer",
	Ignored = "Ignoré",
	Instant = "Instantané",
	["In Tentative Party"] = "En équipe provisoire",
	["Last offered: %s ago"] = "Finie il y a %s",
	["Mission duration"] = "durée de mission",
	["Mission expiration"] = "expiration de mission",
	["Mission level"] = "niveau de mission",
	["Mission order:"] = "Missions triées par :",
	["Missions of Interest"] = "Missions intéressantes",
	["Mitigated threats"] = "menaces contrées",
	["Potential counters:"] = "Oppositions potentiels.",
	Ready = "Prêt",
	["Redundant followers:"] = "Sujets en surnombre :",
	["Reward: %s XP"] = "Récompense : %s d'EXP",
	["Right-click to clear all tentative parties."] = "Faites un clic droit pour effacer tous les groupes provisoires.",
	["Select a follower to focus on"] = "Choisissez un sujet sur lequel se concentrer.",
	["Send Tentative Parties"] = "Envoyer les groupes provisoires",
	["+%s experience expected"] = "Expérience attendue : +%s",
	["%sk"] = "%s k",
	Skipped = "Passé",
	["Start Missions"] = "Commencer les missions",
	Success = "Réussite",
	["Success chance"] = "Chances de réussite",
	["Suggested groups"] = "Groupes suggérés",
	["%s XP"] = "%s EXP",
	["%s XP gained"] = "%s EXP gagnés",
	["%s XP/h"] = "%s EXP/h",
	["This follower could counter the following threats:"] = "Ce sujet peut contrecarrer les menaces suivantes :",
	["Time Horizon"] = "Horizon temporel",
	[ [=[Time until you next expect to be able to interact with garrison missions.

This may affect suggested groups and mission sorting order.]=] ] = [=[Temps restant supposé avant de pouvoir interagir avec les missions du fief.

Peut affecter la suggestion de groupes et l'ordre de tri des missions.]=],
	Unignore = "Ne pas ignorer",
	["Unique ability rerolls:"] = "Relance des capacités spéciales :",
	["View Rewards"] = "Voir les récompenses",
	["You have no followers to counter this mechanic."] = "Vous n'avez aucun sujet pour contrer cette menace.",
	["You have no followers who activate this trait."] = "Vous n'avez pas de sujet avec ce profil.",
	["You have no followers with duplicate counter combinations."] = "Vous n'avez aucun sujets avec une combinaison de contre-attaque en double.",
	["You have no followers with this trait."] = "Vous n'avez aucun sujet avec ce profil.",
	["You have no free bag slots."] = "Vous n'avez plus de place dans vos sacs.",
	["You must restart World of Warcraft after installing this update."] = "Vous devez redémarrer World of Warcraft après avoir installé cette mise à jour.",
} or
L == "itIT" and {
	["*"] = "*",
	["Active Missions (%d)"] = "Missioni Attive (%d)",
	["Additional mission loot may be delivered via mail."] = "Ulteriori ricompense potrebbero essere inviate via posta.",
	["An additional random ability is unlocked when this follower reaches epic quality."] = "Quando questo seguace raggiunge una qualità epica sblocca un'abilità casuale addizionale.",
	["Available; expires in %s"] = "Disponibile; scade in %s",
	["Available Missions (%d)"] = "Missioni Disponibili (%d)",
	["Can be countered by:"] = "Può essere contrastato da:",
	["Chance of success"] = "Probabilità di successo",
	["Click to view upgrade options"] = "Clicca per opzioni di upgrade",
	["Complete All"] = "Completa Tutto",
	["Complete Missions"] = "Completa Missioni",
	["Complete party"] = "Completa gruppo",
	["%dh %dm"] = "%dh %dm",
	["+%d Inactive (hold ALT to view)"] = "+%d Inattivo (tieni premuto ALT per visualizzare)",
	Done = "Fine",
	["%d%% success chance"] = "%d%% probabilità di successo",
	["Duplicate counters"] = "Contrasti duplicati",
	["Epic Ability"] = "Abilità epica",
	["Expedited mission completion"] = "Completamento missioni rapido",
	["Expires in:"] = "Scade in:",
	Failed = "Fallita",
	["Follower experience"] = "Esperienza seguace",
	["Follower experience per hour"] = "Esperienza seguace all'ora",
	["Followers activating this trait:"] = "Seguaci che attivano questo tratto:",
	["Followers with this trait:"] = "Seguaci con questo tratto:",
	["Follower XP"] = "XP seguace",
	["Future Mission #%d"] = "Missione futura #%d",
	["Garrison resources"] = "Risorse guarnigione",
	["Group %d"] = "Gruppo %d",
	["Group suggestions will be updated to include the selected follower."] = "I suggerimenti sul gruppo verranno aggiornati per includere il seguace selezionato.",
	Idle = "in attesa",
	["Idle (max-level)"] = "in attesa (livello-max)",
	Ignore = "Ignora",
	Ignored = "Ignorato",
	Instant = "Istantaneo",
	["In Tentative Party"] = "Nel Gruppo Provvisorio",
	["Last offered: %s ago"] = "Ultima volta completata: %s fa",
	["Mission duration"] = "Durata missione",
	["Mission expiration"] = "Scadenza missione",
	["Mission level"] = "Livello missione",
	["Mission order:"] = "Ordina missioni per:",
	["Missions of Interest"] = "Missioni di Interesse",
	["Mitigated threats"] = "Minacce mitigate",
	["Potential counters:"] = "Contrasti potenziali:",
	Ready = "Pronta",
	["Redundant followers:"] = "Seguaci superflui:",
	["Reward: %s XP"] = "Ricompensa: %s XP",
	["Right-click to clear all tentative parties."] = "Click-destro per rimuovere tutti i gruppi provvisori.",
	["Select a follower to focus on"] = "Seleziona un seguace su cui concentrarsi",
	["Send Tentative Parties"] = "Invia Gruppi Provvisori",
	["+%s experience expected"] = "+%s esperienza stimata",
	["%sk"] = "%sk",
	Skipped = "Saltata",
	["Start Missions"] = "Inizia Missioni",
	Success = "Riuscita",
	["Success chance"] = "Probabilità di successo",
	["Suggested groups"] = "Gruppi suggeriti",
	["%s XP"] = "%s XP",
	["%s XP gained"] = "%s XP ottenuti",
	["%s XP/h"] = "%s XP/h",
	["This follower could counter the following threats:"] = "Questo seguace potrebbe contrastare le seguenti minacce:",
	["Time Horizon"] = "Orizzonte Temporale",
	[ [=[Time until you next expect to be able to interact with garrison missions.

This may affect suggested groups and mission sorting order.]=] ] = [=[Tempo previsto fino al prossimo controllo delle missioni di guarnigione.

Ciò può influenzare i gruppi suggeriti e l'ordine delle missioni.]=],
	Unignore = "Non ignorare",
	["Unique ability rerolls:"] = "Modifiche abilità unica:",
	["View Rewards"] = "Mostra Ricompense",
	["You have no followers to counter this mechanic."] = "Non hai seguaci per contrastare questa meccanica.",
	["You have no followers who activate this trait."] = "Non hai seguaci che attivano questo tratto.",
	["You have no followers with duplicate counter combinations."] = "Non hai seguaci con combinazioni di contrasti duplicati.",
	["You have no followers with this trait."] = "Non hai seguaci con questo tratto.",
	["You have no free bag slots."] = "Non hai spazio nelle borse.",
	["You must restart World of Warcraft after installing this update."] = "È necessario riavviare World of Warcraft dopo l'installazione di questo aggiornamento.",
} or
L == "koKR" and {
	["*"] = "*",
	["Active Missions (%d)"] = "수행 중인 임무 (%d)",
	["Additional mission loot may be delivered via mail."] = "추가 임무 보상은 우편을 통해 올 수도 있습니다.",
	["An additional random ability is unlocked when this follower reaches epic quality."] = "추종자가 영웅 등급이 되면 위협 요소 제거 능력중 하나가 무작위로 추가됩니다.",
	["Available; expires in %s"] = "현재 수행 가능; %s 후 만료",
	["Available Missions (%d)"] = "가능한 임무 (%d)",
	["Can be countered by:"] = "제거 가능 추종자:",
	["Chance of success"] = "성공 확률",
	["Click to view upgrade options"] = "업그레이드 옵션을 보려면 클릭",
	["Complete All"] = "모두 완료",
	["Complete Missions"] = "임무 완료",
	["Complete party"] = "파티 완성시키기",
	["%dh %dm"] = "%d시간 %d분",
	["+%d Inactive (hold ALT to view)"] = "+%d명의 비활성화 추종자 (보려면 ALT키)",
	Done = "완료",
	["%d%% success chance"] = "성공 확률 %d%%",
	["Duplicate counters"] = "중복된 위협 요소 제거 능력",
	["Epic Ability"] = "영웅 등급 능력",
	["Expedited mission completion"] = "임무 완료 빠르게 보기",
	["Expires in:"] = "만료 시간:",
	Failed = "실패",
	["Follower experience"] = "추종자 경험치",
	["Follower experience per hour"] = "시간당 추종자 경험치",
	["Followers activating this trait:"] = "이 속성이 적용되는 추종자:",
	["Followers with this trait:"] = "이 속성을 지닌 추종자:",
	["Follower XP"] = "추종자 경험치",
	["Future Mission #%d"] = "향후 추가될 임무 %d번",
	["Garrison resources"] = "주둔지 자원",
	["Group %d"] = "%d그룹 ",
	["Group suggestions will be updated to include the selected follower."] = "선택한 추종자를 포함하기 위해 추천 그룹이 갱신됩니다.",
	Idle = "대기중",
	["Idle (max-level)"] = "대기중 (최고레벨)",
	Ignore = "무시",
	Ignored = "무시됨",
	Instant = "즉시 수행",
	["In Tentative Party"] = "임시 파티에 있음",
	["Last offered: %s ago"] = "최근 임무 받음: %s 전",
	["Mission duration"] = "임무 수행 시간",
	["Mission expiration"] = "임무 만료 시간",
	["Mission level"] = "임무 레벨",
	["Mission order:"] = "임무 정렬:",
	["Missions of Interest"] = "주요 고소득 임무",
	["Mitigated threats"] = "제거된 위협 요소 갯수",
	["Potential counters:"] = "붙을 수 있는 위협 요소 제거 능력:",
	Ready = "준비 완료",
	["Redundant followers:"] = "필요 없는 추종자:",
	["Reward: %s XP"] = "보상: 경험치 %s",
	["Right-click to clear all tentative parties."] = "우클릭하면 모든 임시 파티를 초기화 합니다.",
	["Select a follower to focus on"] = "주시해서 키울 추종자 선택",
	["Send Tentative Parties"] = "임시 파티 임무 보내기",
	["+%s experience expected"] = "예상 경험치 +%s ",
	["%sk"] = "%s천",
	Skipped = "완료 대기",
	["Start Missions"] = "임무 수행 시작",
	Success = "성공",
	["Success chance"] = "성공 확률",
	["Suggested groups"] = "추천 그룹",
	["%s XP"] = "경험치 %s",
	["%s XP gained"] = "경험치 %s 획득",
	["%s XP/h"] = "%s 경험치/시간",
	["This follower could counter the following threats:"] = "이 추종자는 다음의 위협 요소를 제거할 수 있습니다:",
	["Time Horizon"] = "시간 범위",
	[ [=[Time until you next expect to be able to interact with garrison missions.

This may affect suggested groups and mission sorting order.]=] ] = [=[주둔지 임무 수행이 가능하리라 예상되는 다음 시점입니다.

이 기능은 추천 그룹과 임무 정렬 순서에 적용됩니다.]=],
	Unignore = "무시 취소",
	["Unique ability rerolls:"] = "고유 능력 재배정:",
	["View Rewards"] = "보상 보기",
	["You have no followers to counter this mechanic."] = "이 위협 요소를 제거할 추종자가 없습니다.",
	["You have no followers who activate this trait."] = "이 속성이 적용되는 추종자가 없습니다.",
	["You have no followers with duplicate counter combinations."] = "중복된 위협 요소 제거 능력을 가진 추종자가 없습니다.",
	["You have no followers with this trait."] = "이 속성을 가진 추종자가 없습니다.",
	["You have no free bag slots."] = "가방에 빈 공간이 없습니다.",
	["You must restart World of Warcraft after installing this update."] = "해당 업데이트이후에 월드 오브 워크래프트를 재시작해주셔야 합니다.",
} or
L == "ptBR" and {
	["*"] = "*",
	["Active Missions (%d)"] = "Missões Ativas (%d)",
	["Additional mission loot may be delivered via mail."] = "Saque adicional de missões poderá ser entregue por correio.",
	["Available; expires in %s"] = "Disponível; expira em %s",
	["Available Missions (%d)"] = "Missões Disponíveis (%d)",
	["Can be countered by:"] = "Combatido por:",
	["Chance of success"] = "Chance de sucesso",
	["Click to view upgrade options"] = "Aperte para ver as opções de melhoria",
	["Complete All"] = "Completar Todas",
	["Complete Missions"] = "Missões Completadas",
	["Complete party"] = "Grupo completo",
	["%dh %dm"] = "%dh %dm",
	Done = "Feito",
	["%d%% success chance"] = "%d%% chance de sucesso",
	["Epic Ability"] = "Capacidade épico",
	["Expedited mission completion"] = "Completar missões rapidamente",
	["Expires in:"] = "Encerra em:",
	Failed = "Falhou",
	["Follower experience"] = "Experiência do seguidor",
	["Follower experience per hour"] = "Experiência do seguidor por hora",
	["Followers with this trait:"] = "Seguidores com esta característica:",
	["Follower XP"] = "Seguidor XP",
	["Future Mission #%d"] = "Futuro Missão #%d",
	["Garrison resources"] = "Recursos da guarnição",
	["Group %d"] = "Grupo %d",
	Idle = "Desocupado(s)",
	["Idle (max-level)"] = "Desocupado(s) (nível máximo)",
	Ignore = "Ignorar",
	Ignored = "Ignorado",
	["In Tentative Party"] = "Em Grupo Provisório",
	["Mission duration"] = "Duração da missão",
	["Mission expiration"] = "Expiração da missão",
	["Mission level"] = "Nível da Missão",
	["Mission order:"] = "Ordem das Missões:",
	["Missions of Interest"] = "Missões de interesse",
	["Mitigated threats"] = "Ameaças mitigadas",
	Ready = "Pronto",
	["Reward: %s XP"] = "Recompensa: %s XP",
	["+%s experience expected"] = "+%s experiência esperada",
	["%sk"] = "%sk",
	Skipped = "Ignorados",
	Success = "Sucesso",
	["Success chance"] = "Change de sucesso",
	["Suggested groups"] = "Grupos Sugeridos",
	["%s XP"] = "%s XP",
	["%s XP gained"] = "%s XP obtido",
	["%s XP/h"] = "%s XP/h",
	Unignore = "Designorar",
	["View Rewards"] = "Ver Recompensas",
	["You have no followers to counter this mechanic."] = "Você não tem seguidores para conter esta ameaça.",
	["You have no followers with this trait."] = "Não tem seguidores com esta especialização.",
	["You have no free bag slots."] = "Você não tem espaço livre nas bolsas.",
	["You must restart World of Warcraft after installing this update."] = "Você deve reiniciar o World of Warcraft após instalar esta atualização",
} or
L == "ruRU" and {
	["*"] = "*",
	["Active Missions (%d)"] = "Активные задания (%d)",
	["Additional mission loot may be delivered via mail."] = "Дополнительная добыча с задания может быть доставлена по почте.",
	["An additional random ability is unlocked when this follower reaches epic quality."] = "Дополнительная случайная способность появится по достижении соратником эпического качества.",
	["Available; expires in %s"] = "Доступные; истекает в %s",
	["Available Missions (%d)"] = "Доступные задания (%d)",
	["Can be countered by:"] = "Может быть нейтрализовано:",
	["Chance of success"] = "Вероятность успеха",
	["Click to view upgrade options"] = "Нажмите для просмотра улучшений",
	["Complete All"] = "Завершить все",
	["Complete Missions"] = "Завершить задания",
	["Complete party"] = "Собрать группу",
	["%dh %dm"] = "%dч %dм",
	["+%d Inactive (hold ALT to view)"] = "+%d Неактивный (удерживайте ALT для просмотра)",
	Done = "Завершено",
	["%d%% success chance"] = "%d%% вероятность успеха",
	["Duplicate counters"] = "Одинаковые противодействия",
	["Epic Ability"] = "Эпическая способность",
	["Expedited mission completion"] = "Ускоренное завершение заданий",
	["Expires in:"] = "Истекает через",
	Failed = "Провалено",
	["Follower experience"] = "Опыт соратника",
	["Follower experience per hour"] = "Опыт соратника в час",
	["Followers activating this trait:"] = "Соратники, активирующие эту особенность:",
	["Followers with this trait:"] = "Соратники с данной особенностью:",
	["Follower XP"] = "XP соратника",
	["Future Mission #%d"] = "Будущее задание #%d",
	["Garrison resources"] = "Ресурсы гарнизона",
	["Group %d"] = "Группа %d",
	Idle = "Свободных",
	["Idle (max-level)"] = "Свободных (макс. ур.)",
	Ignore = "Игнорировать",
	Ignored = "Игнорируется",
	["In Tentative Party"] = "В предварительной группе",
	["Last offered: %s ago"] = "Завершено в последний раз: %s назад",
	["Mission duration"] = "Длительность задания",
	["Mission expiration"] = "Истечение срока задания",
	["Mission level"] = "Уровень задания",
	["Mission order:"] = "Сортировка заданий:",
	["Missions of Interest"] = "Важные задания",
	["Mitigated threats"] = "Нейтрализованные угрозы",
	["Potential counters:"] = "Возможно нейтрализовать:",
	Ready = "Готово",
	["Redundant followers:"] = "Резервные соратники",
	["Reward: %s XP"] = "Награда: %s XP",
	["+%s experience expected"] = "+%s ожидаемый опыт",
	["%sk"] = "%sк",
	Skipped = "Пропущено",
	Success = "Успешно",
	["Success chance"] = "Вероятность успеха",
	["Suggested groups"] = "Предлагаемые группы",
	["%s XP"] = "%s XP",
	["%s XP gained"] = "%s XP получено",
	["%s XP/h"] = "%s XP/ч",
	["This follower could counter the following threats:"] = "Соратник может нейтрализовать угрозы:",
	Unignore = "Не игнорировать",
	["View Rewards"] = "Посмотреть награды",
	["You have no followers to counter this mechanic."] = "У вас нет соратников, чтобы  противостоять данной способности.",
	["You have no followers who activate this trait."] = "У вас нет соратников, активирующих эту особенность.",
	["You have no followers with duplicate counter combinations."] = "У вас нет соратников с одинаковыми комбинациями противодействий.",
	["You have no followers with this trait."] = "У вас нет соратников с данной особенностью.",
	["You have no free bag slots."] = "У вас нет места в сумках.",
	["You must restart World of Warcraft after installing this update."] = "Вы должны перезапустить World of Warcraft после установки этого обновления.",
} or
L == "zhCN" and {
	["*"] = "*",
	["Active Missions (%d)"] = "已激活任务（%d）",
	["Additional mission loot may be delivered via mail."] = "任务奖励将以邮件形式发送。",
	["An additional random ability is unlocked when this follower reaches epic quality."] = "当此追随者达到史诗品质时解锁一个附加随机技能。",
	["Available; expires in %s"] = "可用；期限：%s",
	["Available Missions (%d)"] = "可用任务（%d）",
	["Can be countered by:"] = "可以应对：",
	["Chance of success"] = "成功几率",
	["Click to view upgrade options"] = "点击查看升级选项",
	["Complete All"] = "全部完成",
	["Complete Missions"] = "任务完成",
	["Complete party"] = "完成队伍",
	["%dh %dm"] = "%d时 %d分",
	["+%d Inactive (hold ALT to view)"] = "+%d 未激活（按 Alt 查看）",
	Done = "完成",
	["%d%% success chance"] = "%d%% 成功几率",
	["Duplicate counters"] = "重复应对",
	["Epic Ability"] = "史诗技能",
	["Expedited mission completion"] = "加速完成任务",
	["Expires in:"] = "期限：",
	Failed = "失败",
	["Follower experience"] = "追随者经验",
	["Follower experience per hour"] = "每小时追随者经验",
	["Followers activating this trait:"] = "追随者激活此专长：",
	["Followers with this trait:"] = "有此专长的追随者：",
	["Follower XP"] = "追随者经验",
	["Future Mission #%d"] = "未来任务#%d",
	["Garrison resources"] = "要塞资源",
	["Group %d"] = "组合 %d",
	["Group suggestions will be updated to include the selected follower."] = "队伍建议将被更新，以包括所选择的追随者。",
	Idle = "空闲",
	["Idle (max-level)"] = "空闲（满级）",
	Ignore = "忽略",
	Ignored = "已忽略",
	Instant = "立即",
	["In Tentative Party"] = "在预设队伍中",
	["Last offered: %s ago"] = "上次下单：%s 前",
	["Mission duration"] = "任务时间",
	["Mission expiration"] = "任务期限",
	["Mission level"] = "任务等级",
	["Mission order:"] = "任务排序：",
	["Missions of Interest"] = "值得关注任务",
	["Mitigated threats"] = "减少威胁",
	["Potential counters:"] = "潜在应对能力：",
	Ready = "就绪",
	["Redundant followers:"] = "多余的追随者：",
	["Reward: %s XP"] = "奖励：%s 经验",
	["Right-click to clear all tentative parties."] = "右击清除全部暂选队伍。",
	["Select a follower to focus on"] = "选择一个重点追随者",
	["Send Tentative Parties"] = "派遣暂选队伍",
	["+%s experience expected"] = "预计 +%s 经验",
	["%sk"] = "%sk",
	Skipped = "已忽略",
	["Start Missions"] = "开始任务",
	Success = "成功",
	["Success chance"] = "成功几率",
	["Suggested groups"] = "推荐组合",
	["%s XP"] = "%s 经验",
	["%s XP gained"] = "获得 %s 经验",
	["%s XP/h"] = "%s 经验/时",
	["This follower could counter the following threats:"] = "此追随者能够应对以下威胁：",
	["Time Horizon"] = "时间跨度",
	[ [=[Time until you next expect to be able to interact with garrison missions.

This may affect suggested groups and mission sorting order.]=] ] = [=[距离下次希望能够与要塞任务进行交互的时间。

这可能会影响建议的队伍和任务排序顺序。]=],
	Unignore = "取消忽略",
	["Unique ability rerolls:"] = "重选独特技能：",
	["View Rewards"] = "查看奖励",
	["You have no followers to counter this mechanic."] = "你没有追随者应对这种威胁。",
	["You have no followers who activate this trait."] = "没有追随者激活这个专长。",
	["You have no followers with duplicate counter combinations."] = "追随者没有重复的应对组合。",
	["You have no followers with this trait."] = "无有此专长的追随者。",
	["You have no free bag slots."] = "你没有多余的背包空间。",
	["You must restart World of Warcraft after installing this update."] = "安装更新之后必须重启魔兽世界。",
} or
L == "zhTW" and {
	["*"] = "*",
	["Active Missions (%d)"] = "正在進行(%s)",
	["Additional mission loot may be delivered via mail."] = "額外的任務獎勵可能會透過郵件寄送",
	["An additional random ability is unlocked when this follower reaches epic quality."] = "在追隨者達到史詩等級後將解鎖一個額外的隨機技能",
	["Available; expires in %s"] = "可用的；%s後到期",
	["Available Missions (%d)"] = "可執行的任務(%d)",
	["Can be countered by:"] = "反制於：",
	["Chance of success"] = "成功機率",
	["Click to view upgrade options"] = "點擊檢視升級選項",
	["Complete All"] = "全部完成",
	["Complete Missions"] = "完成任務",
	["Complete party"] = "完成隊伍",
	["%dh %dm"] = "%d小時 %d分",
	["+%d Inactive (hold ALT to view)"] = "+%d 停用的(按下Alt來觀看)",
	Done = "完成",
	["%d%% success chance"] = "%d%% 成功機率",
	["Duplicate counters"] = "重複技能",
	["Epic Ability"] = "第二技能",
	["Expedited mission completion"] = "快速完成任務",
	["Expires in:"] = "期限：",
	Failed = "失敗",
	["Follower experience"] = "追隨者經驗值",
	["Follower experience per hour"] = "每小時經驗值",
	["Followers activating this trait:"] = "啟用此特長的追隨者：",
	["Followers with this trait:"] = "有此特長的追隨者:",
	["Follower XP"] = "追隨者經驗值",
	["Future Mission #%d"] = "未來任務 #%d",
	["Garrison resources"] = "要塞資源",
	["Group %d"] = "隊伍 %d",
	["Group suggestions will be updated to include the selected follower."] = "隊伍建議將根據被選擇的追隨者作更新。",
	Idle = "閒置",
	["Idle (max-level)"] = "閒置(最高等級)",
	Ignore = "忽略",
	Ignored = "已忽略",
	Instant = "馬上",
	["In Tentative Party"] = "在暫定隊伍中",
	["Last offered: %s ago"] = "最後完成：%s前",
	["Mission duration"] = "任務持續時間",
	["Mission expiration"] = "任務期限",
	["Mission level"] = "任務等級",
	["Mission order:"] = "任務排序:",
	["Missions of Interest"] = "重點任務",
	["Mitigated threats"] = "反制威脅",
	["Potential counters:"] = "可能反制：",
	Ready = "完成",
	["Redundant followers:"] = "多餘的追隨者：",
	["Reward: %s XP"] = "獎勵: %s 經驗值",
	["Right-click to clear all tentative parties."] = "右鍵取消所有暫定隊伍",
	["Select a follower to focus on"] = "選擇一個重點追隨者",
	["Send Tentative Parties"] = "派出所有暫定隊伍",
	["+%s experience expected"] = "經驗期望值: %s ",
	["%sk"] = "%sk",
	Skipped = "略過",
	["Start Missions"] = "開始任務",
	Success = "成功",
	["Success chance"] = "成功機率",
	["Suggested groups"] = "建議的隊伍",
	["%s XP"] = "%s 經驗值",
	["%s XP gained"] = "獲得 %s 經驗值",
	["%s XP/h"] = "%s 每小時經驗值",
	["This follower could counter the following threats:"] = "此追隨者將可能反制以下威脅：",
	["Time Horizon"] = "時間範圍",
	[ [=[Time until you next expect to be able to interact with garrison missions.

This may affect suggested groups and mission sorting order.]=] ] = [=[距離你下次能回來與指派要塞任務的時間。

這可能會改變建議的隊伍和任務排序。]=],
	Unignore = "解除忽略",
	["Unique ability rerolls:"] = "非重複組合機會:",
	["View Rewards"] = "檢視獎勵",
	["You have no followers to counter this mechanic."] = "你沒有追隨者能反制此威脅",
	["You have no followers who activate this trait."] = "你沒有啟用此特長的追隨者。",
	["You have no followers with duplicate counter combinations."] = "您沒有重複技能組合的追隨者。",
	["You have no followers with this trait."] = "你沒有追隨者具備此特長",
	["You have no free bag slots."] = "你的背包沒有足夠的空間",
	["You must restart World of Warcraft after installing this update."] = "安裝此更新後，你必須重新啟動魔獸世界",
} or
{}