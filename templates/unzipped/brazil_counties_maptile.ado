*! 26nov2019, Diana Goldemberg

program define _maptile_brazil_counties
	syntax , [  geofolder(string) ///
				mergedatabase ///
				map spmapvar(varname) var(varname) binvar(varname) clopt(string) legopt(string) min(string) clbreaks(string) max(string) mapcolors(string asis) ndfcolor(string) ///
				savegraph(string) replace resolution(string) map_restriction(string) spopt(string) ///
        /* Geography-specific options */ ///
  			stateoutline(string) ]

	if ("`mergedatabase'"!="") {
		novarabbrev merge 1:m county_code using `"`geofolder'/brazil_counties_database.dta"', nogen
		exit
	}

	if ("`map'"!="") {

    if ("`stateoutline'"!="") {
			cap confirm file `"`geofolder'/brazil_states_coords.dta"'
			if (_rc==0) local polygon polygon(data(`"`geofolder'/brazil_states_coords"') ocolor(black) osize(`stateoutline' ...) )
			else if (_rc==601) {
				di as error `"stateoutline() requires the {it:brazil_states} geography to be installed"'
				di as error `"--> brazil_states_coords.dta must be present in the geofolder"'
				exit 198
			}
			else {
				error _rc
				exit _rc
			}
		}

		spmap `spmapvar' using `"`geofolder'/brazil_counties_coords.dta"' `map_restriction', id(_polygonid) ///
			`clopt' ///
			`legopt' ///
			legend(pos(5) size(*1.8)) ///
			fcolor(`mapcolors') ndfcolor(`ndfcolor') ///
			oc(white ...) ndo(white) ///
			os(vvthin ...) nds(vvthin) ///
      `polygon' ///
			`spopt'

		* Save graph
		if (`"`savegraph'"'!="") __savegraph_maptile, savegraph(`savegraph') resolution(`resolution') `replace'

	}

end

* Save map to file
cap program drop __savegraph_maptile
program define __savegraph_maptile

	syntax, savegraph(string) resolution(string) [replace]

	* check file extension using a regular expression
	if regexm(`"`savegraph'"',"\.[a-zA-Z0-9]+$") local graphextension=regexs(0)

	* deal with different filetypes appropriately
	if inlist(`"`graphextension'"',".gph","") graph save `"`savegraph'"', `replace'
	else if inlist(`"`graphextension'"',".ps",".eps") graph export `"`savegraph'"', mag(`=round(100*`resolution')') `replace'
	else if (`"`graphextension'"'==".png") graph export `"`savegraph'"', width(`=round(3200*`resolution')') `replace'
	else if (`"`graphextension'"'==".tif") graph export `"`savegraph'"', width(`=round(1600*`resolution')') `replace'
	else graph export `"`savegraph'"', `replace'

end
