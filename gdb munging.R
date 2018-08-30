
### Using shapefiles and geodatabase tables. 

rm(list = ls()) # clear global environment 
cat("\014") # clear the console 
dev.off() 

library(maptools)
library(rgdal) 
library(rgeos)
library(sf) 


### Set working drive 
setwd("/Users/chriseshleman/Dropbox/Work and research/Airport noise pollution/data and models/hedonic")
list.files("./HR&A Advisors") 

### These are geodatabase files. 
ogrListLayers("./HR&A_Advisors.gdb")

### FIRST ATTEMPT 
# From Lauren O'Brien via http://r-sig-geo.2731867.n2.nabble.com/Reading-tables-without-geometry-from-gdb-td7591820.html

# somewhere to dump outputs 
dir.create(file.path(getwd(), 'HR&A_tables')) 

# whats in the gdb? 
gdb_contents = st_layers(dsn = file.path(getwd(), './HR&A_Advisors.gdb'), 
                         do_count = TRUE) 

# this is easier to read than the list above: 
gdb_neat_deets = data.frame('Name' = gdb_contents[['name']], 
                            'Geomtype' = unlist(gdb_contents[['geomtype']]), 
                            'features' = gdb_contents[['features']], 
                            'fields' = gdb_contents[['fields']]) 

# so the non-spatial tables have geometry == NA, lets get their names 
properties_nonspatial = 
  as.list(gdb_neat_deets[is.na(gdb_neat_deets$Geomtype), 'Name']) 

# names attrib is useful here 
names(properties_nonspatial) = 
  gdb_neat_deets[is.na(gdb_neat_deets$Geomtype), 'Name'] 

# pull all the non-spatial layers out to csv using GDAL: 
lapply(seq_along(properties_nonspatial), function(x) { 
  system2('C:/OSGeo4W64/bin/ogr2ogr.exe', 
          args = c(# output format 
            '-f', 'csv', 
            # overwrite 
            '-overwrite', 
            # destination file 
            file.path(getwd(), 
                      'HR&A_tables', 
                      paste0(names(properties_nonspatial[x]), '.csv')), 
            # src file 
            file.path(getwd(), './HR&A_Advisors.gdb'), properties_nonspatial[x])) 
}) 

### Uh oh. Doesn't know what I'm trying to do via  "system2('C:/OSGeo4W64/bin/ogr2ogr.exe'," 
