function dir_valid = direction_validity(conn_new, conn_old)
    dir_valid = false;
    if strcmp(conn_new, 'DUAL') 
        dir_valid = true;
    elseif strcmp(conn_old, 'DUAL')
        dir_valid = true;
    elseif strcmp(conn_new, 'IN') && strcmp(conn_old, 'OUT')
        dir_valid = true;
    elseif strcmp(conn_new, 'OUT') && strcmp(conn_old, 'IN') 
        dir_valid = true;
    end 
end