use [chamomile];

go

/*
	select * from [repository].[get_list](N'documentation')
	where [fqn] like N'%prototype%'
	order by [fqn];
*/
declare @job_name [sysname] = N'demonstration_job';
declare @object_fqn    [nvarchar](max) =(select N'['
                 + isnull(lower(cast(serverproperty(N'InstanceName') as [sysname])), N'default')
                 + N'].[msdb].['
                 + cast(lower([job_id]) as [sysname])
                 + N'].[' + [name] + N']'
          from   [msdb].[dbo].[sysjobs] as [sysjobs]
          where  [name] = @job_name),
        @step_fqn      [nvarchar](max),
        @data          [xml],
        @description   [nvarchar](max) = N'test ',
        @documentation [xml] = N'<documentation job_id="" job_fqn="" />',
        @sequence      [int] = 0,
        @delete        [int] = 0,
        @stack         xml([chamomile].[xsc]) = null,
        @procedure_id  [int] = @@procid,
        @timestamp     [sysname] = convert([sysname], current_timestamp, 126),
        @prototype     [xml],
        @job_id        [uniqueidentifier],
        @builder       [xml];

set @job_id = (select [job_id]
               from   [msdb].[dbo].[sysjobs] as [sysjobs]
               where  [sysjobs].[name] = @job_name);
set @documentation.modify(N'replace value of (/*/@job_fqn)[1] with sql:variable("@object_fqn")');
set @documentation.modify(N'replace value of (/*/@job_id)[1] with sql:variable("@job_id")');

begin
    begin transaction;

    --
    -------------------------------------------
    set @prototype = [utility].[get_prototype](N'[chamomile].[documentation_stack].[stack].[prototype]');

    select @data = N'<data job_id="7efc4311-a80f-4748-ac98-e599fd8fc40a" job_name="demonstration_job" job_step="" ><any_valid_xml />
		</data>'
           , @description = N'WHAN that Aprille with his shoures soote 1	
The droghte 2 of Marche hath perced to the roote,	
And bathed every veyne in swich 3 licour,	
Of which vertu engendred is the flour;	
Whan Zephirus eek with his swete breeth	        5
Inspired hath in every holt 4 and heeth	
The tendre croppes, 5 and the yonge sonne	
Hath in the Ram his halfe cours y-ronne, 6	
And smale fowles maken melodye,	
That slepen al the night with open ye,	        10
(So priketh hem nature in hir corages: 7	
Than longen folk to goon on pilgrimages,	
And palmers for to seken straunge strondes, 8	
To ferne halwes, 9 couthe 10 in sondry londes;	
And specially, from every shires ende	        15
Of Engelond, to Caunterbury they wende,	
The holy blisful martir for to seke,	
That hem hath holpen, whan that they were seke. 11	
  Bifel that, in that sesoun on a day,	
In Southwerk at the Tabard as I lay 12	        20
Redy to wenden on my pilgrimage	
To Caunterbury with ful devout corage,	
At night was come in-to that hostelrye	
Wel 13 nyne and twenty in a compaignye,	
Of sondry folk, by aventure 14 y-falle 15	        25
In felawshipe, and pilgrims were they alle,	
That toward Caunterbury wolden ryde;	
The chambres and the stables weren wyde,	
And wel we weren esed atte beste. 16	
And shortly, whan the sonne was to reste,	        30
So hadde I spoken with hem everichon, 17	
That I was of hir felawshipe anon,	
And made forward 18 erly for to ryse,	
To take our wey, ther as I yow devyse. 19	
  But natheles, 20 whyl I have tyme and space,	        35
Er that I ferther in this tale pace, 21	
Me thinketh it acordaunt to resoun,	
To telle yew al the condicioun 22	
Of ech of hem, so as it semed me,	
And whiche 23 they weren, and of what degree;	        40
And eek in what array that they were inne:	
And at a knight than wol I first biginne.	
  A KNIGHT ther was, and that a worthy man,	
That fro the tyme that he first bigan	
To ryden out, he loved chivalrye,	        45
Trouthe and honour, fredom 24 and curteisye.	
Ful worthy was he in his lordes werre, 25	
And thereto 26 hadde he riden (no man ferre 27)	
As wel in cristendom as hethenesse,	
And evere honoured for his worthinesse.	        50
  At Alisaundre he was, whan it was wonne;	
Ful ofte tyme he hadde the bord bigonne 28	
Aboven alle naciouns in Pruce. 29	
In Lettow 30 hadde he reysed 31 and in Ruce, 32	
No cristen man so ofte of his degree.	        55
In Gernade 33 at the sege eek hadde he be	
Of Algezir, and riden in Belmarye. 34	
At Lyeys 35 was he, and at Satalye, 36	
Whan they were wonne; and in the Grete See 37	
At many a noble aryve 38 hadde he be,	        60
At mortal batailles hadde he been fiftene,	
And foughten for our feith at Tramissene 39	
In listes thryes, and ay slayn his foo.	
This ilke 40 worthy knight hadde been also	
Somtyme with the lord of Palatye, 41	        65
Ageyn another hethen in Turkye:	
And everemore he hadde a sovereyn prys. 42	
And though that he were worthy, he was wys,	
And of his port 43 as meek as is a mayde.	
He nevere yet no vileinye 44 ne sayde	        70
In al his lyf, un-to no maner wight. 45	
He was a verray parfit gentil knight.	
But for to tellen yow of his array,	
His hors were goode, but he was nat gay.	
Of fustian 46 he wered a gipoun 47	        75
Al bismotered 48 with his habergeoun. 49	
For he was late y-come from his viage, 50	
And wente for to doon his pilgrimage.	
  With him ther was his sone, a yong SQUYER,	
A lovyer, and a lusty bacheler,	        80
With lokkes crulle, 51 as they were leyd in presse.	
Of twenty yeer of age he was, I gesse.	
Of his stature he was of evene lengthe, 52	
And wonderly delivere, 53 and greet of strengthe.	
And he hadde been somtyme in chivachye, 54	        85
In Flaundres, in Artoys, and Picardye,	
And born him wel, as of so litel space, 55	
In hope to stonden in his lady 56 grace.	
Embrouded was he, as it were a mede	
Al ful of fresshe floures, whyte and rede.	        90
Singinge he was, or floytinge, 57 al the day;	
He was as fresh as is the month of May.	
Short was his goune, with sleves longe and wyde.	
Wel coude he sitte on hors, and faire ryde.	
He coude songes make and wel endyte, 58	        95
Iuste and eek daunce, and wel purtreye and wryte.	
So hote he lovede, that by nightertale 59	
He sleep namore than doth a nightingale.	
Curteys he was, lowly, and servisable,	
And carf 60 biforn his fader at the table.	        100
A YEMAN hadde he, 61 and servaunts namo 62	
At that tyme, for him liste 63 ryde so;	
And he was clad in cote and hood of grene;	
A sheef 64 of pecok arwes brighte and kene	
Under his belt he bar ful thriftily,	        105
(Wel coude he dresse his takel yemanly:	
His arwes drouped noght with fetheres lowe),	
And in his hand he bar a mighty bowe.	
A not-heed 65 hadde he, with a broun visage.	
Of wode-craft wel coude 66 he al the usage.	        110
Upon his arm he bar a gay bracer, 67	
And by his syde a swerd and a bokeler,	
And on that other syde a gay daggere,	
Harneised 68 wel, and sharp as point of spere;	
A Cristofre 69 on his brest of silver shene	        115
An horn he bar, the bawdrik 70 was of grene;	
A forster was he, soothly, as I gesse.	
  Ther was also a Nonne, a PRIORESSE,	
That of hir smyling was ful simple and coy;	
Hir gretteste ooth was but by seynt Loy; 71	        120
And she was cleped 72 madame Eglentyne.	
Ful wel she song the service divyne,	
Entuned in hir nose ful semely;	
And Frensh she spak ful faire and fetisly, 73	
After the scole of Stratford atte Bowe, 74	        125
For Frensh of Paris was to hir unknowe.	
At mete wel y-taught was she with-alle;	
She leet no morsel from hir lippes falle,	
Ne wette hir fingres in hir sauce depe.	
Wel coude she carie a morsel, and wel kepe,	        130
That no drope ne fille up-on hir brest.	
In curteisye was set ful moche hir lest. 75	
Hir over lippe 76 wyped she so clene,	
That in hir coppe was no ferthing 77 sene	
Of grece, whan she dronken hadde hir draughte.	        135
Ful semely after hir mete she raughte, 78	
And sikerly 79 she was of greet disport, 80	
And ful plesaunt, and amiable of port,	
And peyned hir to countrefete chere 81	
Of court, and been estatlich 82 of manere,	        140
And to ben holden digne 83 of reverence.	
But, for to speken of hir conscience, 84	
She was so charitable and so pitous,	
She wolde wepe, if that she sawe a mous	
Caught in a trappe, if it were deed or bledde.	        145
Of smale houndes had she, that she fedde	
With rosted flesh, or milk and wastel breed. 85	
But sore weep she if oon of hem were deed,	
Or if men smoot it with a yerde 86 smerte:	
And al was conscience 87 and tendre herte.	        150
Ful semely 88 hir wimpel 89 pinched 90 was;	
Hir nose tretys; 91 hir eyen greye as glas;	
Hir mouth ful smal, and ther-to softe and reed;	
But sikerly she hadde a fair forheed.	
It was almost a spanne brood, I trowe;	        155
For, hardily, 92 she was nat undergrowe.	
Ful fetis 93 was hir cloke, as I was war.	
Of smal coral aboute hir arm she bar	
A peire 94 of bedes, gauded 95 al with grene;	
And ther-on heng a broche of gold ful shene,	        160
On which ther was first write a crowned A,	
And after, Amor vincit omnia. 96	
  Another NONNE with hir hadde she,	
That was hir chapeleyne, and PREESTES thre.	
  A MONK ther was, a fair for the maistrye, 97	        165
An out-rydere, 98 that lovede venerye; 99	
A manly man, to been an abbot able.	
Ful many a deyntee hors hadde he in stable:	
And, whan he rood, men mighte his brydel here	
Ginglen in a whistling wynd as clere,	        170
And eek as loude as dooth the chapel-belle,	
Ther-as 100 this lord was keper of the celle. 101	
The reule of seint Maure or of seint Beneit,	
By-cause that it was old and som-del streit, 102	
This ilke monk leet olde thinges pace,	        175
And held after the newe world the space.	
He yaf 103 nat of that text a pulled 104 hen,	
That seith, that hunters been nat holy men;	
Ne that a monk, whan he is cloisterlees 105	
Is likned til a fish that is waterlees;	        180
This is to seyn, a monk out of his cloistre.	
But thilke text held he nat worth an oistre.	
And I seyde his opinioun was good.	
What sholde he studie, and make him-selven wood, 106	
Upon a book in cloistre alwey to poure,	        185
Or swinken 107 with his handes, and laboure,	
As Austin bit? 108 How shal the world be served?	
Lat Austin have his swink to him reserved.	
Therfor he was a pricasour 109 aright;	
Grehoundes he hadde, as swifte as fowel in flight;	        190
Of priking 110 and of hunting for the hare	
Was al his lust, for no cost wolde he spare.	
I seigh 111 his sleves purfiled 112 at the hond	
With grys, 113 and that the fyneste of a lond;	
And, for to festne his hood under his chin,	        195
He hadde of gold y-wroght a curious pin:	
A love-knot in the gretter ende ther was.	
His heed was balled, that shoon as any glas,	
And eek his face, as he hadde been anoint.	
He was a lord ful fat and in good point;';

    set @data.modify(N'replace value of (/log/@timestamp)[1] with sql:variable("@timestamp")');
    set @description = coalesce(@description
                                , @data.value(N'(/*/description/text())[1]'
                                              , N'[nvarchar](max)'));

    execute [chamomile].[documentation].[set]
      @object_fqn =@object_fqn,
      @description =@description,
      @prototype =@prototype,
      @data =@data,
      @sequence =@sequence,
      @delete =@delete,
      @stack =@stack output;

    --
    -------------------------------------------
    set @prototype = [utility].[get_prototype](N'[chamomile].[documentation_stack].[stack].[prototype]');

    select @data = N'<data job_id="7efc4311-a80f-4748-ac98-e599fd8fc40a" job_name="demonstration_job" job_step="" ><and_yet_still_valid_xml />
		</data>';

    set @data.modify(N'replace value of (/log/@timestamp)[1] with sql:variable("@timestamp")');
    set @description = coalesce(@description
                                , @data.value(N'(/*/description/text())[1]'
                                              , N'[nvarchar](max)'));

    execute [chamomile].[documentation].[set]
      @object_fqn =@object_fqn,
      @description =@description,
      @prototype =@prototype,
      @data =@data,
      @sequence =@sequence,
      @delete =@delete,
      @stack =@stack output;

    --
    -------------------------------------------
    set @prototype = [utility].[get_prototype](N'[chamomile].[documentation_stack].[stack].[prototype]');

    select @data = N'<data job_id="7efc4311-a80f-4748-ac98-e599fd8fc40a" job_name="demonstration_job" job_step="" ><more_and_more_valid_xml_or_html><ol><li>line one</li><li>line 2</li></ol></more_and_more_valid_xml_or_html>
		</data>';

    set @data.modify(N'replace value of (/log/@timestamp)[1] with sql:variable("@timestamp")');
    set @description = coalesce(@description
                                , @data.value(N'(/*/description/text())[1]'
                                              , N'[nvarchar](max)'));

    execute [chamomile].[documentation].[set]
      @object_fqn =@object_fqn,
      @description =@description,
      @prototype =@prototype,
      @data =@data,
      @sequence =@sequence,
      @delete =@delete,
      @stack =@stack output;

    select [chamomile].[documentation].[get](@object_fqn) as [job_documentation];

    --
    -------------------------------------------
    select @step_fqn = @object_fqn
                       + N'.[step_01].[does_something_interesting]'
           , @description = N'why am I here anyway at step one anyway?';

    set @prototype = [utility].[get_prototype](N'[chamomile].[documentation_stack].[stack].[prototype]');
    set @data = N'<data job_id="7efc4311-a80f-4748-ac98-e599fd8fc40a" job_name="demonstration_job" job_step="1" ><some_weird_instructions_or_data />
		</data>'
    set @data.modify(N'replace value of (/log/@timestamp)[1] with sql:variable("@timestamp")');

    execute [chamomile].[documentation].[set]
      @object_fqn =@step_fqn,
      @description =@description,
      @prototype =@prototype,
      @data =@data,
      @sequence =@sequence,
      @delete =@delete,
      @stack =@stack output;

    select [chamomile].[documentation].[get](@step_fqn) as [first_step];

    --
    -------------------------------------------
    select @step_fqn = @object_fqn
                       + N'.[step_02].[just_tries_to_be_interesting]'
           , @description = N'interesting stuff about step 2';

    set @prototype = [utility].[get_prototype](N'[chamomile].[documentation_stack].[stack].[prototype]');
    set @data = N'<data job_id="7efc4311-a80f-4748-ac98-e599fd8fc40a" job_name="demonstration_job" job_step="2" ><object>
				  <parameter_list>
					<company>05</company>
					<contract_number>DF40000763</contract_number>
					<cms_trr_trans_status_code>M</cms_trr_trans_status_code>
					<trr_reply_code>177</trr_reply_code>
					<id_cms_enrollment_interface>21124827</id_cms_enrollment_interface>
				  </parameter_list>
				</object>
    		</data>';
    set @data.modify(N'replace value of (/log/@timestamp)[1] with sql:variable("@timestamp")');

    execute [chamomile].[documentation].[set]
      @object_fqn =@step_fqn,
      @description =@description,
      @prototype =@prototype,
      @data =@data,
      @sequence =@sequence,
      @delete =@delete,
      @stack =@stack output;

    select [chamomile].[documentation].[get](@step_fqn) as [second_step];

    --
    -------------------------------------------
    with [data_builder]
         as (select t2.c.query(N'.')                   as [documentation_stack]
                    , t2.c.query(N'./*')               as [documentation]
                    , t2.c.value(N'(./data/@job_id)[1]'
                                 , N'[nvarchar](max)') as [job_id]
                    , t2.c.value(N'(./data/@job_name)[1]'
                                 , N'[nvarchar](max)') as [job_name]
                    , t2.c.value(N'(./data/@job_step)[1]'
                                 , N'[nvarchar](max)') as [job_step]
                    , t2.c.value(N'(./@fqn)[1]'
                                 , N'[nvarchar](max)') as [fqn]
                    , cast(N'<text>'
                           + t2.c.value(N'(./description/text())[1]', N'[nvarchar](max)')
                           + N'</text>' as [xml])      as [text]
                    , t.c.query(N'./*')                as [data]
             from   [chamomile].[documentation].[get_list](@object_fqn)
                    cross apply [entry].nodes(N'/*/object/documentation_stack/data') as t(c)
                    cross apply [entry].nodes(N'/*/object/documentation_stack') as t2(c))
    select [job_id]
           , [job_name]
           , [job_step]
           , [fqn]
           , [data]
           , [text]
    from   [data_builder]
    order  by [fqn];

    --
    ---------------------------------------------
    select cast(N'<job_details><details><summary>[job_details]</summary>
            			   <table>
						   <tr><td>id</td><td>'
                + cast([job_id] as [sysname])
                + N'</td></tr>
						   <tr><td>originating server </td><td>'
                + cast([servers].[name] as [sysname])
                + N'</td></tr>
            			   <tr><td>description </td><td>'
                + [sysjobs].[description]
                + N'</td></tr>
						   <tr><td>owner</td><td>'
                + cast(suser_sname([sysjobs].[owner_sid]) as [sysname])
                + N'</td></tr>
						   <tr><td>job category</td><td>'
                + cast([syscategories].[name] as [sysname])
                + N'</td></tr>
						   <tr><td>created</td><td>'
                + cast([sysjobs].[date_created] as [sysname])
                + N'</td></tr>
						   <tr><td>modified</td><td>'
                + cast([sysjobs].[date_modified] as [sysname])
                + N'</td></tr>
                           <tr><td>version</td><td>'
                + cast([sysjobs].[version_number] as [sysname])
                + N'</td></tr>'
                + N'</table></details></job_details>' as [xml])
    from   [msdb].[dbo].[sysjobs] as [sysjobs]
           join [msdb].[sys].[servers] as [servers]
             on [sysjobs].[originating_server_id] = [servers].[server_id]
           join [msdb].[dbo].[syscategories] as [syscategories]
             on [sysjobs].[category_id] = [syscategories].[category_id]
    where  [sysjobs].[name] = @job_name;

    rollback;
end; 
