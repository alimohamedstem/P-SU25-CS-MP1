include("plot_graph.jl")
include("scoring.jl")
using Makie.Colors 
using Random
using StatsBase
using Colors

mutable struct NodeInfo
    label::Int
    neighbors::Vector{Int}
end

function label_propagation(g, node_info)
    label_changed = true
    while label_changed
        label_changed = false
        shuffled_nodes = shuffle(1:nv(g))
        for n in shuffled_nodes
            neighbor_labels = [node_info[j].label for j in node_info[n].neighbors]
            most_common = findmax(countmap(neighbor_labels))[2]
            if node_info[n].label != most_common
                node_info[n].label = most_common
                label_changed = true
            end
        end
    end
end

function main(filename = "graph05.txt")
    edge_list = read_edges(filename)
    g = build_graph(edge_list)

    # Build a dictionary mapping node indices to the node's info
    node_info = Dict{Int, NodeInfo}()
    for n in 1:nv(g)
        node_info[n] = NodeInfo(n, collect(neighbors(g, n)))
    end
    
    # Run label propagation
    label_propagation(g, node_info)

    # Use a fixed-size color palette for cycling, e.g., 16 colors
    palette_size = 16
    color_palette = Makie.distinguishable_colors(palette_size)

    # Assign initial color indices based on label (but allow cycling through all palette colors)
    labels = unique([node.label for node in values(node_info)])
    label_to_color_index = Dict(labels[i] => mod1(i, palette_size) for i in eachindex(labels))
    node_color_indices = [label_to_color_index[node_info[n].label] for n in 1:nv(g)]
    node_colors = [color_palette[i] for i in node_color_indices]
    node_text_colors = [Colors.Lab(RGB(c)).l > 50 ? :black : :white for c in node_colors]

    interactive_plot_graph(g, node_info, node_colors, node_text_colors, node_color_indices, color_palette)

    # Report the score
    score = dave_score(g, node_info, node_color_indices)
    println("score is $score")
end

main()