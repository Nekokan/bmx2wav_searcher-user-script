// ----- ColumnGroup 関連 ------------------------------------------------

{
  local group = ColumnGroup( "フォルダ分け用" );
  group.columns.append( HeaderColumn( "TITLE", HeaderColumn.compare_as_string ) );
  group.columns.append( HeaderColumn( "ARTIST", HeaderColumn.compare_as_string ) );
  group.columns.append( ParentDirectoryColumn() );
  group.columns.append( ParentsParentDirectoryColumn() );
  Searcher.column_groups.append( group );
}

// ----- SearchMethod 関連 -----------------------------------------------

// -- LeastPlaylevelSearchMethod (more than zero, exclude only one chart )
class LeastPlaylevelSearchMethod extends SearchMethod {
  constructor() {
    base.constructor( "フォルダ毎最低LEVEL(>0)のみ" );
  }

  function search( entry ) {
    return this.filter.filtering( entry );
  }

  function by_each_directory( directory_entry, entry_array ) {
    if ( entry_array.len() > 0 ) {
      Searcher.add_directory_entry_to_list( directory_entry );
    }

    local key = "PLAYLEVEL";
    local current = null;
    foreach ( entry in entry_array ) {
      entry.parse_as_bms_data_once();

      if ( key in entry.bms_data.headers ) {
        try {
          if ( current == null ) {
            current = entry;
          }
          else if ( current.bms_data.headers[key].tointeger() <= 0 ){
            current.search_hit = false;
            current = entry;
          }
          else if ( current.bms_data.headers[key].tointeger() < entry.bms_data.headers[key].tointeger() ||  entry.bms_data.headers[key].tointeger() <= 0 ) {
            entry.search_hit = false;
          }
          else {
            current.search_hit = false;
            current = entry;
          }
        }
        catch ( e ) {
          // continue;
        }
      }
    }
  }

  filter = ExtensionsFilter( StrT.Searcher.Main.Toolbar.SearchMethodFilterBmsGeneral.get(), "bms", "bme", "bml", "pms" );
}

// -- 登録
Searcher.search_methods.append( LeastPlaylevelSearchMethod() );

