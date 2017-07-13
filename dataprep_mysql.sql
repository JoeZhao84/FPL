
SELECT DATEDIFF(day, '2014/01/01', '2014/04/28');

/*select * from datascience.dbo.jozh_opta_19_24*/
/*select * from datascience.dbo.jozh_opta_30*/
select * from datascience.dbo.jozh_opta_38


IF OBJECT_ID('tempdb.dbo.#jozh_opta', 'U') IS NOT NULL DROP TABLE #jozh_opta
select distinct c.calendardate, a.*
into #jozh_opta 
from datascience.dbo.jozh_opta_38 as a
left join datascience.dbo.jozh_team_mapping as b
on a.Club = b.shortName
left join datascience.dbo.jozh_results1 as c
on a.gameweek = c.gameweek and (b.longName = c.hometeam or b.longName = c.awayteam)

select * from #jozh_opta where club = 'ARS' order by gameweek

/*select * from datascience.dbo.jozh_resultodds_28*/
select * from datascience.dbo.jozh_resultodds_38
/*drop table datascience.dbo.jozh_resultodds_38*/
select * from datascience.dbo.jozh_team_mapping
select * from datascience.dbo.jozh_stadiumlocation

select * from datascience.dbo.jozh_pts_lastS
/*drop table datascience.dbo.jozh_pts_lastS*/

IF OBJECT_ID('tempdb.dbo.#jozh_stadium', 'U') IS NOT NULL DROP TABLE #jozh_stadium
select  [Stadium name], team, cast(capacity as int) as capacity, cast(Latitude as float) as Latitude, cast(Longitude as float) as Longitude, longName
into #jozh_stadium 
from datascience.dbo.jozh_stadiumlocation

select * from #jozh_stadium 

/*assign pts on each match result*/

	IF OBJECT_ID('datascience.dbo.jozh_results1', 'U') IS NOT NULL DROP TABLE datascience.dbo.jozh_results1
	select gameweek, CAST(calendarDate AS DATE) as calendardate, hometeam, awayteam, case when ftr = 'A' then 0 when ftr = 'D' then 1 when ftr = 'H' then 3 end as homepts, 
	case when ftr = 'A' then 3 when ftr = 'D' then 1 when ftr = 'H' then 0 end as awaypts, ftr, cast(FTHG as int) * 1.0 as FTHG, cast(FTAG as int) * 1.0 as FTAG 
	into datascience.dbo.jozh_results1
	from datascience.dbo.jozh_resultodds_38

	select * from datascience.dbo.jozh_results1

/*calculate the total homepts and awaypts of the home team and away team before the match*/;

	IF OBJECT_ID('tempdb.dbo.#jozh_hometeam_homepts', 'U') IS NOT NULL DROP TABLE #jozh_hometeam_homepts
	select a.calendardate, a.hometeam, cast((sum(b.homepts) * 1.0 / count(b.homepts)) as float) as hometeam_homepts_per_match
	into #jozh_hometeam_homepts
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.hometeam = b.hometeam and a.calendardate > b.calendardate)
	group by a.hometeam, a.calendardate
	select * from #jozh_hometeam_homepts

	IF OBJECT_ID('tempdb.dbo.#jozh_hometeam_awaypts', 'U') IS NOT NULL DROP TABLE #jozh_hometeam_awaypts
	select a.calendardate, a.hometeam, cast((sum(b.awaypts) * 1.0 / count(b.awaypts)) as float) as hometeam_awaypts_per_match
	into #jozh_hometeam_awaypts
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.hometeam = b.awayteam and a.calendardate > b.calendardate)
	group by a.hometeam, a.calendardate

	IF OBJECT_ID('tempdb.dbo.#jozh_awayteam_homepts', 'U') IS NOT NULL DROP TABLE #jozh_awayteam_homepts
	select a.calendardate, a.awayteam, cast((sum(b.homepts) * 1.0 / count(b.homepts)) as float) as awayteam_homepts_per_match
	into #jozh_awayteam_homepts
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.awayteam = b.hometeam and a.calendardate > b.calendardate)
	group by a.awayteam, a.calendardate

	IF OBJECT_ID('tempdb.dbo.#jozh_awayteam_awaypts', 'U') IS NOT NULL DROP TABLE #jozh_awayteam_awaypts
	select a.calendardate, a.awayteam, cast((sum(b.awaypts) * 1.0 / count(b.awaypts)) as float) as awayteam_awaypts_per_match
	into #jozh_awayteam_awaypts
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.awayteam = b.awayteam and a.calendardate > b.calendardate)
	group by a.awayteam, a.calendardate

	IF OBJECT_ID('datascience.dbo.jozh_results2', 'U') IS NOT NULL DROP TABLE datascience.dbo.jozh_results2
	select a.*, b.hometeam_homepts_per_match, c.hometeam_awaypts_per_match, d.awayteam_homepts_per_match, e.awayteam_awaypts_per_match
	into datascience.dbo.jozh_results2
	from datascience.dbo.jozh_results1 as a 
	left join #jozh_hometeam_homepts as b
	on a.hometeam = b.hometeam and a.calendardate = b.calendardate
	left join #jozh_hometeam_awaypts as c
	on a.hometeam = c.hometeam and a.calendardate = c.calendardate
	left join #jozh_awayteam_homepts as d
	on a.awayteam = d.awayteam and a.calendardate = d.calendardate
	left join #jozh_awayteam_awaypts as e
	on a.awayteam = e.awayteam and a.calendardate = e.calendardate

	select * from datascience.dbo.jozh_results2 where hometeam = 'Arsenal' or awayteam = 'Arsenal'
	order by calendardate

/*calculate the total homepts and awaypts of the home team and away team in the last 30 days before the match*/;
	IF OBJECT_ID('tempdb.dbo.#jozh_hometeam_homepts_form', 'U') IS NOT NULL DROP TABLE #jozh_hometeam_homepts_form
	select a.calendardate, a.hometeam, sum(b.FTHG) as hometeam_homeGoalAg_form, sum(b.FTAG) as hometeam_homeGoalCon_form, 
	sum(b.homepts) as hometeam_homepts_form, count(b.homepts) as hometeam_homematches_form
	into #jozh_hometeam_homepts_form
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.hometeam = b.hometeam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 30)
	group by a.hometeam, a.calendardate;

	IF OBJECT_ID('tempdb.dbo.#jozh_hometeam_awaypts_form', 'U') IS NOT NULL DROP TABLE #jozh_hometeam_awaypts_form
	select a.calendardate, a.hometeam, sum(b.FTAG) as hometeam_awayGoalAg_form, sum(b.FTHG) as hometeam_awayGoalCon_form, 
	sum(b.awaypts) as hometeam_awaypts_form, count(b.awaypts) as hometeam_awaymatches_form
	into #jozh_hometeam_awaypts_form
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.hometeam = b.awayteam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 30)
	group by a.hometeam, a.calendardate

	IF OBJECT_ID('tempdb.dbo.#jozh_awayteam_homepts_form', 'U') IS NOT NULL DROP TABLE #jozh_awayteam_homepts_form
	select a.calendardate, a.awayteam, sum(b.FTHG) as awayteam_homeGoalAg_form, sum(b.FTAG) as awayteam_homeGoalCon_form, 
	sum(b.homepts) as awayteam_homepts_form, count(b.homepts) as awayteam_homematches_form
	into #jozh_awayteam_homepts_form
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.awayteam = b.hometeam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 30)
	group by a.awayteam, a.calendardate

	IF OBJECT_ID('tempdb.dbo.#jozh_awayteam_awaypts_form', 'U') IS NOT NULL DROP TABLE #jozh_awayteam_awaypts_form
	select a.calendardate, a.awayteam, sum(b.FTAG) as awayteam_awayGoalAg_form, sum(b.FTHG) as awayteam_awayGoalCon_form, 
	sum(b.awaypts) as awayteam_awaypts_form, count(b.awaypts) as awayteam_awaymatches_form
	into #jozh_awayteam_awaypts_form
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.awayteam = b.awayteam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 30)
	group by a.awayteam, a.calendardate


	IF OBJECT_ID('datascience.dbo.jozh_results3', 'U') IS NOT NULL DROP TABLE datascience.dbo.jozh_results3
	select a.*, b.hometeam_homeGoalAg_form, b.hometeam_homeGoalCon_form, b.hometeam_homepts_form, b.hometeam_homematches_form, c.hometeam_awayGoalAg_form, 
	c.hometeam_awayGoalCon_form, c.hometeam_awaypts_form, c.hometeam_awaymatches_form, d.awayteam_homeGoalAg_form, d.awayteam_homeGoalCon_form,
	d.awayteam_homepts_form, d.awayteam_homematches_form, e.awayteam_awayGoalAg_form, e.awayteam_awayGoalCon_form, e.awayteam_awaypts_form, e.awayteam_awaymatches_form
	into datascience.dbo.jozh_results3
	from datascience.dbo.jozh_results2 as a 
	left join #jozh_hometeam_homepts_form as b
	on a.hometeam = b.hometeam and a.calendardate = b.calendardate
	left join #jozh_hometeam_awaypts_form as c
	on a.hometeam = c.hometeam and a.calendardate = c.calendardate
	left join #jozh_awayteam_homepts_form as d
	on a.awayteam = d.awayteam and a.calendardate = d.calendardate
	left join #jozh_awayteam_awaypts_form as e
	on a.awayteam = e.awayteam and a.calendardate = e.calendardate


	select * from datascience.dbo.jozh_results3 where hometeam = 'Arsenal' or awayteam = 'Arsenal'
	order by calendardate

	/*calculate the total homepts and awaypts of the home team and away team in the last *60*@ days before the match*/;
	IF OBJECT_ID('tempdb.dbo.#jozh_hometeam_homepts_form1', 'U') IS NOT NULL DROP TABLE #jozh_hometeam_homepts_form1
	select a.calendardate, a.hometeam, sum(b.FTHG) as hometeam_homeGoalAg_form1, sum(b.FTAG) as hometeam_homeGoalCon_form1, sum(b.homepts) as hometeam_homepts_form1, count(b.homepts) as hometeam_homematches_form1
	into #jozh_hometeam_homepts_form1
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.hometeam = b.hometeam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 60)
	group by a.hometeam, a.calendardate;

	IF OBJECT_ID('tempdb.dbo.#jozh_hometeam_awaypts_form1', 'U') IS NOT NULL DROP TABLE #jozh_hometeam_awaypts_form1
	select a.calendardate, a.hometeam, sum(b.FTAG) as hometeam_awayGoalAg_form1, sum(b.FTHG) as hometeam_awayGoalCon_form1, sum(b.awaypts) as hometeam_awaypts_form1, count(b.awaypts) as hometeam_awaymatches_form1
	into #jozh_hometeam_awaypts_form1
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.hometeam = b.awayteam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 60)
	group by a.hometeam, a.calendardate

	IF OBJECT_ID('tempdb.dbo.#jozh_awayteam_homepts_form1', 'U') IS NOT NULL DROP TABLE #jozh_awayteam_homepts_form1
	select a.calendardate, a.awayteam, sum(b.FTHG) as awayteam_homeGoalAg_form1, sum(b.FTAG) as awayteam_homeGoalCon_form1, sum(b.homepts) as awayteam_homepts_form1, count(b.homepts) as awayteam_homematches_form1
	into #jozh_awayteam_homepts_form1
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.awayteam = b.hometeam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 60)
	group by a.awayteam, a.calendardate

	IF OBJECT_ID('tempdb.dbo.#jozh_awayteam_awaypts_form1', 'U') IS NOT NULL DROP TABLE #jozh_awayteam_awaypts_form1
	select a.calendardate, a.awayteam, sum(b.FTAG) as awayteam_awayGoalAg_form1, sum(b.FTHG) as awayteam_awayGoalCon_form1, sum(b.awaypts) as awayteam_awaypts_form1, count(b.awaypts) as awayteam_awaymatches_form1
	into #jozh_awayteam_awaypts_form1
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.awayteam = b.awayteam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 60)
	group by a.awayteam, a.calendardate

	IF OBJECT_ID('datascience.dbo.jozh_results31', 'U') IS NOT NULL DROP TABLE datascience.dbo.jozh_results31
	select a.*, b.hometeam_homeGoalAg_form1, b.hometeam_homeGoalCon_form1, b.hometeam_homepts_form1, b.hometeam_homematches_form1, c.hometeam_awayGoalAg_form1, 
	c.hometeam_awayGoalCon_form1, c.hometeam_awaypts_form1, c.hometeam_awaymatches_form1, d.awayteam_homeGoalAg_form1, d.awayteam_homeGoalCon_form1,
	d.awayteam_homepts_form1, d.awayteam_homematches_form1, e.awayteam_awayGoalAg_form1, e.awayteam_awayGoalCon_form1, e.awayteam_awaypts_form1, e.awayteam_awaymatches_form1
	into datascience.dbo.jozh_results31
	from datascience.dbo.jozh_results3 as a 
	left join #jozh_hometeam_homepts_form1 as b
	on a.hometeam = b.hometeam and a.calendardate = b.calendardate
	left join #jozh_hometeam_awaypts_form1 as c
	on a.hometeam = c.hometeam and a.calendardate = c.calendardate
	left join #jozh_awayteam_homepts_form1 as d
	on a.awayteam = d.awayteam and a.calendardate = d.calendardate
	left join #jozh_awayteam_awaypts_form1 as e
	on a.awayteam = e.awayteam and a.calendardate = e.calendardate


	select * from datascience.dbo.jozh_results31 where hometeam = 'Arsenal' or awayteam = 'Arsenal'
	order by calendardate

/*calculate the past 30 days opponent strength - awaypts_permatch for home opponent and vice versa*/;
	IF OBJECT_ID('tempdb.dbo.#jozh_hometeam_homeoppo_awaypts', 'U') IS NOT NULL DROP TABLE #jozh_hometeam_homeoppo_awaypts
	select a.calendardate, a.hometeam, sum(b.awayteam_awaypts_per_match) as hometeam_homeoppo_awaypts, count(b.awayteam_awaypts_per_match) as hometeam_homeoppo_match
	into #jozh_hometeam_homeoppo_awaypts
	from datascience.dbo.jozh_results2 as a
	left join datascience.dbo.jozh_results2 as b
	on (a.hometeam = b.hometeam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 30)
	group by a.hometeam, a.calendardate;

	IF OBJECT_ID('tempdb.dbo.#jozh_hometeam_awayoppo_homepts', 'U') IS NOT NULL DROP TABLE #jozh_hometeam_awayoppo_homepts
	select a.calendardate, a.hometeam, sum(b.hometeam_homepts_per_match) as hometeam_awayoppo_homepts, count(b.hometeam_homepts_per_match) as hometeam_awayoppo_match
	into #jozh_hometeam_awayoppo_homepts
	from datascience.dbo.jozh_results2 as a
	left join datascience.dbo.jozh_results2 as b
	on (a.hometeam = b.awayteam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 30)
	group by a.hometeam, a.calendardate;

	IF OBJECT_ID('tempdb.dbo.#jozh_awayteam_homeoppo_awaypts', 'U') IS NOT NULL DROP TABLE #jozh_awayteam_homeoppo_awaypts
	select a.calendardate, a.awayteam, sum(b.awayteam_awaypts_per_match) as awayteam_homeoppo_awaypts, count(b.awayteam_awaypts_per_match) as awayteam_homeoppo_match
	into #jozh_awayteam_homeoppo_awaypts
	from datascience.dbo.jozh_results2 as a
	left join datascience.dbo.jozh_results2 as b
	on (a.awayteam = b.hometeam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 30)
	group by a.awayteam, a.calendardate;

	IF OBJECT_ID('tempdb.dbo.#jozh_awayteam_awayoppo_homepts', 'U') IS NOT NULL DROP TABLE #jozh_awayteam_awayoppo_homepts
	select a.calendardate, a.awayteam, sum(b.hometeam_homepts_per_match) as awayteam_awayoppo_homepts, count(b.hometeam_homepts_per_match) as awayteam_awayoppo_match
	into #jozh_awayteam_awayoppo_homepts
	from datascience.dbo.jozh_results2 as a
	left join datascience.dbo.jozh_results2 as b
	on (a.awayteam = b.awayteam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 30)
	group by a.awayteam, a.calendardate;


	IF OBJECT_ID('datascience.dbo.jozh_results32', 'U') IS NOT NULL DROP TABLE datascience.dbo.jozh_results32
	select a.*, b.hometeam_homeoppo_awaypts, b.hometeam_homeoppo_match, c.hometeam_awayoppo_homepts, c.hometeam_awayoppo_match, 
	d.awayteam_homeoppo_awaypts, d.awayteam_homeoppo_match, e.awayteam_awayoppo_homepts, e.awayteam_awayoppo_match
	into datascience.dbo.jozh_results32
	from datascience.dbo.jozh_results31 as a 
	left join #jozh_hometeam_homeoppo_awaypts as b
	on a.hometeam = b.hometeam and a.calendardate = b.calendardate
	left join #jozh_hometeam_awayoppo_homepts as c
	on a.hometeam = c.hometeam and a.calendardate = c.calendardate
	left join #jozh_awayteam_homeoppo_awaypts as d
	on a.awayteam = d.awayteam and a.calendardate = d.calendardate
	left join #jozh_awayteam_awayoppo_homepts as e
	on a.awayteam = e.awayteam and a.calendardate = e.calendardate


	select * from datascience.dbo.jozh_results32 where hometeam = 'Arsenal' or awayteam = 'Arsenal'
	order by calendardate

/*calculate the key OPTA metrics of the home team and away team before the match*/;
	IF OBJECT_ID('tempdb.dbo.#jozh_hometeam_opta', 'U') IS NOT NULL DROP TABLE #jozh_hometeam_opta
	select a.calendardate, a.hometeam, count(distinct c.gameweek) as hometeam_matches, 
	sum(cast(c.[CBIs Clearances Blocks Interceptions] as int)) * 1.0 / count(distinct c.gameweek) as hometeam_CBI_pm,
	sum(cast(c.[KP Key Pass] as int)) * 1.0 / count(distinct c.gameweek) as hometeam_keypass_pm, 
	sum(cast(c.[Fwd Pas Forward Passes] as int)) * 1.0 / count(distinct c.gameweek) as hometeam_fwdpass_pm,
	sum(cast(c.[C BC Big Chance Created] as int)) * 1.0 / count(distinct c.gameweek) as hometeam_bigchance_pm, 
	sum(cast(c.[Suc Drb Successful Dribbles] as int)) * 1.0 / count(distinct c.gameweek) as hometeam_sucdribbles_pm, 
	sum(cast(c.[Tchs in Box Touches inside opposition Box] as int)) * 1.0 / count(distinct c.gameweek) as hometeam_touchinbox_pm, 
	sum(cast(c.[SoTShots on Target] as int)) * 1.0 / count(distinct c.gameweek) as hometeam_SoT_pm
	into #jozh_hometeam_opta
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_team_mapping as b
	on a.hometeam = b.longName
	left join #jozh_opta as c
	on b.shortName = c.Club and DATEDIFF(day,c.calendardate, a.calendardate) > 0 and DATEDIFF(day,c.calendardate, a.calendardate) < 30
	group by a.hometeam, a.calendardate
	
 select * 
 from #jozh_hometeam_opta
 where hometeam = 'Arsenal'
 order by calendardate

 
 	IF OBJECT_ID('tempdb.dbo.#jozh_awayteam_opta', 'U') IS NOT NULL DROP TABLE #jozh_awayteam_opta
	select a.calendardate, a.awayteam, count(distinct c.gameweek) as awayteam_matches, 
	sum(cast(c.[CBIs Clearances Blocks Interceptions] as int)) * 1.0 / count(distinct c.gameweek) as awayteam_CBI_pm,
	sum(cast(c.[KP Key Pass] as int)) * 1.0 / count(distinct c.gameweek) as awayteam_keypass_pm, 
	sum(cast(c.[Fwd Pas Forward Passes] as int)) * 1.0 / count(distinct c.gameweek) as awayteam_fwdpass_pm,
	sum(cast(c.[C BC Big Chance Created] as int)) * 1.0 / count(distinct c.gameweek) as awayteam_bigchance_pm, 
	sum(cast(c.[Suc Drb Successful Dribbles] as int)) * 1.0 / count(distinct c.gameweek) as awayteam_sucdribbles_pm, 
	sum(cast(c.[Tchs in Box Touches inside opposition Box] as int)) * 1.0 / count(distinct c.gameweek) as awayteam_touchinbox_pm, 
	sum(cast(c.[SoTShots on Target] as int)) * 1.0 / count(distinct c.gameweek) as awayteam_SoT_pm
	into #jozh_awayteam_opta
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_team_mapping as b
	on a.awayteam = b.longName
	left join #jozh_opta as c
	on b.shortName = c.Club and DATEDIFF(day,c.calendardate, a.calendardate) > 0 and DATEDIFF(day,c.calendardate, a.calendardate) < 30
	group by a.awayteam, a.calendardate

select * 
 from #jozh_awayteam_opta
 where awayteam = 'Arsenal'
 order by calendardate


  	IF OBJECT_ID('datascience.dbo.jozh_results4', 'U') IS NOT NULL DROP TABLE datascience.dbo.jozh_results4
	select distinct a.*, b.hometeam_matches, b.hometeam_CBI_pm, b.hometeam_keypass_pm, b.hometeam_fwdpass_pm, b.hometeam_bigchance_pm, 
	b.hometeam_sucdribbles_pm, b.hometeam_touchinbox_pm, b.hometeam_SoT_pm, c.awayteam_matches, c.awayteam_CBI_pm, c.awayteam_keypass_pm, 
	c.awayteam_fwdpass_pm, c.awayteam_bigchance_pm, c.awayteam_sucdribbles_pm, c.awayteam_touchinbox_pm, c.awayteam_SoT_pm
	into datascience.dbo.jozh_results4
	from datascience.dbo.jozh_results32 as a 
	left join #jozh_hometeam_opta as b
	on a.calendardate = b.calendardate and a.hometeam = b.hometeam
	left join #jozh_awayteam_opta as c
	on a.calendardate = c.calendardate and a.awayteam = c.awayteam

select * from datascience.dbo.jozh_results4  where hometeam = 'Arsenal' or awayteam = 'Arsenal'
	order by calendardate

 /*SoT conceded, touch in box conceded and big chance conceded*/
 	IF OBJECT_ID('tempdb.dbo.#jozh_hometeam_homeopta_c', 'U') IS NOT NULL DROP TABLE #jozh_hometeam_homeopta_c
	select a.calendardate, a.hometeam, count(distinct d.gameweek) as hometeam_homematches_c, 
	sum(cast(d.[C BC Big Chance Created] as int)) * 1.0 / count(distinct d.gameweek) as hometeam_homebigchance_pm_c, 
	sum(cast(d.[Tchs in Box Touches inside opposition Box] as int)) * 1.0 / count(distinct d.gameweek) as hometeam_hometouchinbox_pm_c, 
	sum(cast(d.[SoTShots on Target] as int)) * 1.0 / count(distinct d.gameweek) as hometeam_homeSoT_pm_c
	into #jozh_hometeam_homeopta_c
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.hometeam = b.hometeam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 30)
	left join datascience.dbo.jozh_team_mapping as c
	on b.awayteam = c.longName
	left join #jozh_opta as d
	on c.shortName = d.Club and b.gameweek = d.Gameweek
	group by a.hometeam, a.calendardate

 select * 
 from #jozh_hometeam_homeopta_c
 where hometeam = 'Arsenal'
 order by calendardate

 	IF OBJECT_ID('tempdb.dbo.#jozh_hometeam_awayopta_c', 'U') IS NOT NULL DROP TABLE #jozh_hometeam_awayopta_c
	select a.calendardate, a.hometeam, count(distinct d.gameweek) as hometeam_awaymatches_c, 
	sum(cast(d.[C BC Big Chance Created] as int)) * 1.0 / count(distinct d.gameweek) as hometeam_awaybigchance_pm_c, 
	sum(cast(d.[Tchs in Box Touches inside opposition Box] as int)) * 1.0 / count(distinct d.gameweek) as hometeam_awaytouchinbox_pm_c, 
	sum(cast(d.[SoTShots on Target] as int)) * 1.0 / count(distinct d.gameweek) as hometeam_awaySoT_pm_c
	into #jozh_hometeam_awayopta_c
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.hometeam = b.awayteam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 30)
	left join datascience.dbo.jozh_team_mapping as c
	on b.hometeam = c.longName
	left join #jozh_opta as d
	on c.shortName = d.Club and b.gameweek = d.Gameweek
	group by a.hometeam, a.calendardate

 select * 
 from #jozh_hometeam_awayopta_c
 where hometeam = 'Stoke'
 order by calendardate
	
	IF OBJECT_ID('tempdb.dbo.#jozh_hometeam_opta_c', 'U') IS NOT NULL DROP TABLE #jozh_hometeam_opta_c
	select a.*, b.hometeam_awaymatches_c, b.hometeam_awaybigchance_pm_c, b.hometeam_awaytouchinbox_pm_c, b.hometeam_awaySoT_pm_c
	into #jozh_hometeam_opta_c
	from #jozh_hometeam_homeopta_c as a
	left join #jozh_hometeam_awayopta_c as b
	on a.calendardate = b.calendardate and a.hometeam = b.hometeam

 select * 
 from #jozh_hometeam_opta_c
 where hometeam = 'Stoke'
 order by calendardate

  	IF OBJECT_ID('tempdb.dbo.#jozh_awayteam_homeopta_c', 'U') IS NOT NULL DROP TABLE #jozh_awayteam_homeopta_c
	select a.calendardate, a.awayteam, count(distinct d.gameweek) as awayteam_homematches_c, 
	sum(cast(d.[C BC Big Chance Created] as int)) * 1.0 / count(distinct d.gameweek) as awayteam_homebigchance_pm_c, 
	sum(cast(d.[Tchs in Box Touches inside opposition Box] as int)) * 1.0 / count(distinct d.gameweek) as awayteam_hometouchinbox_pm_c, 
	sum(cast(d.[SoTShots on Target] as int)) * 1.0 / count(distinct d.gameweek) as awayteam_homeSoT_pm_c
	into #jozh_awayteam_homeopta_c
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.awayteam = b.hometeam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 30)
	left join datascience.dbo.jozh_team_mapping as c
	on b.awayteam = c.longName
	left join #jozh_opta as d
	on c.shortName = d.Club and b.gameweek = d.Gameweek
	group by a.awayteam, a.calendardate

 select * 
 from #jozh_awayteam_homeopta_c
 where awayteam = 'Arsenal'
 order by calendardate

 	IF OBJECT_ID('tempdb.dbo.#jozh_awayteam_awayopta_c', 'U') IS NOT NULL DROP TABLE #jozh_awayteam_awayopta_c
	select a.calendardate, a.awayteam, count(distinct d.gameweek) as awayteam_awaymatches_c, 
	sum(cast(d.[C BC Big Chance Created] as int)) * 1.0 / count(distinct d.gameweek) as awayteam_awaybigchance_pm_c, 
	sum(cast(d.[Tchs in Box Touches inside opposition Box] as int)) * 1.0 / count(distinct d.gameweek) as awayteam_awaytouchinbox_pm_c, 
	sum(cast(d.[SoTShots on Target] as int)) * 1.0 / count(distinct d.gameweek) as awayteam_awaySoT_pm_c
	into #jozh_awayteam_awayopta_c
	from datascience.dbo.jozh_results1 as a
	left join datascience.dbo.jozh_results1 as b
	on (a.awayteam = b.awayteam and DATEDIFF(day,b.calendardate, a.calendardate) > 0 and DATEDIFF(day,b.calendardate, a.calendardate) < 30)
	left join datascience.dbo.jozh_team_mapping as c
	on b.hometeam = c.longName
	left join #jozh_opta as d
	on c.shortName = d.Club and b.gameweek = d.Gameweek
	group by a.awayteam, a.calendardate

 select * 
 from #jozh_awayteam_awayopta_c
 where awayteam = 'Stoke'
 order by calendardate
	
	IF OBJECT_ID('tempdb.dbo.#jozh_awayteam_opta_c', 'U') IS NOT NULL DROP TABLE #jozh_awayteam_opta_c
	select a.*, b.awayteam_awaymatches_c, b.awayteam_awaybigchance_pm_c, b.awayteam_awaytouchinbox_pm_c, b.awayteam_awaySoT_pm_c
	into #jozh_awayteam_opta_c
	from #jozh_awayteam_homeopta_c as a
	left join #jozh_awayteam_awayopta_c as b
	on a.calendardate = b.calendardate and a.awayteam = b.awayteam

 select * 
 from #jozh_awayteam_opta_c
 where awayteam = 'Stoke'
 order by calendardate

	
  	IF OBJECT_ID('datascience.dbo.jozh_results5', 'U') IS NOT NULL DROP TABLE datascience.dbo.jozh_results5
	select distinct a.*, b.hometeam_homematches_c, b.hometeam_homebigchance_pm_c, b.hometeam_hometouchinbox_pm_c, b.hometeam_homeSoT_pm_c, 
	b.hometeam_awaymatches_c, b.hometeam_awaybigchance_pm_c, b.hometeam_awaytouchinbox_pm_c, b.hometeam_awaySoT_pm_c, 
	c.awayteam_homematches_c, c.awayteam_homebigchance_pm_c, c.awayteam_hometouchinbox_pm_c, c.awayteam_homeSoT_pm_c, 
	c.awayteam_awaymatches_c, c.awayteam_awaybigchance_pm_c, c.awayteam_awaytouchinbox_pm_c, c.awayteam_awaySoT_pm_c 
	into datascience.dbo.jozh_results5
	from datascience.dbo.jozh_results4 as a 
	left join #jozh_hometeam_opta_c as b
	on a.calendardate = b.calendardate and a.hometeam = b.hometeam
	left join #jozh_awayteam_opta_c as c
	on a.calendardate = c.calendardate and a.awayteam = c.awayteam

	select * from datascience.dbo.jozh_results5  where hometeam = 'Arsenal' or awayteam = 'Arsenal'
	order by calendardate

 /*travel distance of the awayteam*/
	IF OBJECT_ID('tempdb.dbo.#awayteam_travel', 'U') IS NOT NULL DROP TABLE #awayteam_travel
	select a.*, sqrt(power((b.Latitude - c.Latitude), 2) + power((b.Longitude - c.Longitude), 2)) as distance, d.B365H, d.B365D, d.B365A, 
	e.Pts_lastS as hometeam_pts_lastS, f.Pts_lastS as awayteam_pts_lastS
	into #awayteam_travel
	from datascience.dbo.jozh_results5 as a 
	left join #jozh_stadium as b
	on a.hometeam = b.longName
	left join #jozh_stadium as c
	on a.awayteam = c.longName
	left join datascience.dbo.jozh_resultodds_32 as d
	on a.calendardate = d.calendardate and a.hometeam = d.hometeam
	left join datascience.dbo.jozh_pts_lastS as e
	on a.hometeam = e.longName
	left join datascience.dbo.jozh_pts_lastS as f
	on a.awayteam = f.longName

select * from #awayteam_travel where hometeam = 'Arsenal' or awayteam = 'Arsenal' order by calendardate



/*house cleaning*/;


