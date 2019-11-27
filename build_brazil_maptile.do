*--------------------------------------------------
* Maptile template for Brazilian Counties
* using the id code = IBGE 7 digits
* 26nov2019, Diana Goldemberg
*--------------------------------------------------

// Imports country boundaries shapefiles into Stata format

// Original input files downloaded from:
// ftp://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2015/Brasil/BR/
// Then simplified in ArcMap using the Bend Simplify Polygon tool with a 0.1 degree tolerance
// http://desktop.arcgis.com/en/arcmap/latest/tools/coverage-toolbox/simplify-line-or-polygon.htm


*** Step 0: Install required ados
foreach command in maptile shp2dta spmap {
  cap which `command'
  if _rc == 111  ssc install `command'
}



* Specify macros
global root "C:/Users/diana/Documents/GitHub/brazil_maptile"
global rawdata "${root}/rawdata"
global outputs "${root}/templates"


local  geoname = "brazil_counties"

*** Step 1: Convert shapefile to dta
shp2dta using "${rawdata}/BRUMUE_simplified", database("${outputs}/`geoname'_database_temp") ///
	coordinates("${outputs}/`geoname'_coords_temp") genid(_polygonid) replace

*** Step 2: Clean database
use "${outputs}/`geoname'_database_temp", clear
rename (NM_MUNICIP CD_GEOCMU) (county_name county_code)
destring county_code, replace
keep county_name county_code _polygonid
saveold "${outputs}/`geoname'_database.dta", replace v(12)

*** Step 3: Clean coordinates
use "${outputs}/`geoname'_coords_temp.dta", clear
clonevar _polygonid = _ID
merge m:1 _polygonid using "${outputs}/`geoname'_database.dta", assert(master match) keep(match) nogen
keep _ID _X _Y
sort _ID, stable
saveold "${outputs}/`geoname'_coords.dta", replace v(12)

*** Step 4: Clean up extra files
erase "${outputs}/`geoname'_database_temp.dta"
erase "${outputs}/`geoname'_coords_temp.dta"


local  geoname = "brazil_states"

shp2dta using "${rawdata}/BRUFE_simplified", database("${outputs}/`geoname'_database_temp") ///
  coordinates("${outputs}/`geoname'_coords_temp") genid(_polygonid) replace

*** Step 2: Clean database
use "${outputs}/`geoname'_database_temp", clear
rename (NM_ESTADO CD_GEOCUF) (state_name state_code)
destring state_code, replace
keep state_name state_code _polygonid
saveold "${outputs}/`geoname'_database.dta", replace v(12)

*** Step 3: Clean coordinates
use "${outputs}/`geoname'_coords_temp.dta", clear
clonevar _polygonid = _ID
merge m:1 _polygonid using "${outputs}/`geoname'_database.dta", assert(master match) keep(match) nogen
keep _ID _X _Y
sort _ID, stable
saveold "${outputs}/`geoname'_coords.dta", replace v(12)

*** Step 4: Clean up extra files
erase "${outputs}/`geoname'_database_temp.dta"
erase "${outputs}/`geoname'_coords_temp.dta"
