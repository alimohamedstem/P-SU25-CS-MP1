function get_score(g, node_info, node_color_indices)
    same_color = 1.0
    different_color = 2.5
    no_connection_same_color = 0.5
    total_score = 0.0
    total_nodes = nv(g)

    for first in 1:total_nodes
        for next in (first+1):total_nodes
            same = node_color_indices[first] == node_color_indices[next]
            connected = has_edge(g, first, next)

            if same
                if connected
                    total_score += same_color
                else
                    total_score -= no_connection_same_color
                end
            else
                if connected
                    total_score -= different_color
                end
            end
        end
    end


    return total_score
end