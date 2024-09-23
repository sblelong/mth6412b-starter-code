export read_header, read_nodes, read_edges, read_stsp, plot_graph

"""Analyse un fichier .tsp et renvoie un dictionnaire avec les données de l'entête."""
function read_header(filename::String)

  file = open(filename, "r")
  header = Dict{String}{String}()
  sections = ["NAME", "TYPE", "COMMENT", "DIMENSION", "EDGE_WEIGHT_TYPE", "EDGE_WEIGHT_FORMAT",
    "EDGE_DATA_FORMAT", "NODE_COORD_TYPE", "DISPLAY_DATA_TYPE"]

  # Initialize header
  for section in sections
    header[section] = "None"
  end

  for line in eachline(file)
    line = strip(line)
    data = split(line, ":")
    if length(data) >= 2
      firstword = strip(data[1])
      if firstword in sections
        header[firstword] = strip(data[2])
      end
    end
  end
  close(file)
  return header
end

"""Analyse un fichier .tsp et renvoie un dictionnaire des noeuds sous la forme {id => [x,y]}.
Si les coordonnées ne sont pas données, un dictionnaire vide est renvoyé.
Le nombre de noeuds est dans header["DIMENSION"]."""
function read_nodes(header::Dict{String}{String}, filename::String)


  node_coord_type = header["NODE_COORD_TYPE"]
  display_data_type = header["DISPLAY_DATA_TYPE"]
  dim = parse(Int, header["DIMENSION"])

  if display_data_type in ["COORDS_DISPLAY", "TWOD_DISPLAY"]
    nodes = Node{Vector{Float64}}[]
  else
    nodes = Node{Float64}[]
  end

  if !(node_coord_type in ["TWOD_COORDS", "THREED_COORDS"]) && !(display_data_type in ["COORDS_DISPLAY", "TWOD_DISPLAY"])
    for i = 1:dim
      push!(nodes, Node(string(i), NaN))
    end
    return nodes
  end

  file = open(filename, "r")
  k = 0
  display_data_section = false
  node_coord_section = false
  flag = false

  for line in eachline(file)
    if !flag
      line = strip(line)
      if line == "DISPLAY_DATA_SECTION"
        display_data_section = true
      elseif line == "NODE_COORD_SECTION"
        node_coord_section = true
      end

      if (display_data_section || node_coord_section) && !(line in ["DISPLAY_DATA_SECTION", "NODE_COORD_SECTION"])
        data = split(line)

        push!(nodes, Node(String(data[1]), map(x -> parse(Float64, x), data[2:end])))

        # Sacha: this line is temporarily put on comment to keep an eye on the old structure.
        # nodes[parse(Int, data[1])] = map(x -> parse(Float64, x), data[2:end])
        k = k + 1
      end

      if k >= dim
        flag = true
      end
    end
  end
  close(file)
  return nodes
end

"""Fonction auxiliaire de read_edges, qui détermine le nombre de noeud à lire
en fonction de la structure du graphe."""
function n_nodes_to_read(format::String, n::Int, dim::Int)
  if format == "FULL_MATRIX"
    return dim
  elseif format in ["LOWER_DIAG_ROW", "UPPER_DIAG_COL"]
    return n + 1
  elseif format in ["LOWER_DIAG_COL", "UPPER_DIAG_ROW"]
    return dim - n
  elseif format in ["LOWER_ROW", "UPPER_COL"]
    return n
  elseif format in ["LOWER_COL", "UPPER_ROW"]
    return dim - n - 1
  else
    error("Unknown format - function n_nodes_to_read")
  end
end

"""Analyse un fichier .tsp et renvoie l'ensemble des arêtes sous la forme d'un tableau."""
function read_edges(header::Dict{String}{String}, filename::String)

  edges = Edge{Int64}[]
  edge_weight_format = header["EDGE_WEIGHT_FORMAT"]
  known_edge_weight_formats = ["FULL_MATRIX", "UPPER_ROW", "LOWER_ROW",
    "UPPER_DIAG_ROW", "LOWER_DIAG_ROW", "UPPER_COL", "LOWER_COL",
    "UPPER_DIAG_COL", "LOWER_DIAG_COL"]

  if !(edge_weight_format in known_edge_weight_formats)
    @warn "unknown edge weight format" edge_weight_format
    return edges
  end

  file = open(filename, "r")
  dim = parse(Int, header["DIMENSION"])
  edge_weight_section = false
  k = 0
  n_edges = 0
  i = 0
  n_to_read = n_nodes_to_read(edge_weight_format, k, dim)
  flag = false

  for line in eachline(file)
    line = strip(line)
    if !flag
      if occursin(r"^EDGE_WEIGHT_SECTION", line)
        edge_weight_section = true
        continue
      end

      if edge_weight_section
        data = split(line)
        n_data = length(data)
        start = 0
        while n_data > 0
          n_on_this_line = min(n_to_read, n_data)

          for j = start:start+n_on_this_line-1
            n_edges = n_edges + 1
            if edge_weight_format in ["UPPER_ROW", "LOWER_COL"]
              edge = Edge(k + 1, i + k + 2, parse(Int, data[j+1]))
            elseif edge_weight_format in ["UPPER_DIAG_ROW", "LOWER_DIAG_COL"]
              edge = Edge(k + 1, i + k + 1, parse(Int, data[j+1]))
            elseif edge_weight_format in ["UPPER_COL", "LOWER_ROW"]
              edge = Edge(i + k + 2, k + 1, parse(Int, data[j+1]))
            elseif edge_weight_format in ["UPPER_DIAG_COL", "LOWER_DIAG_ROW"]
              edge = Edge(i + 1, k + 1, parse(Int, data[j+1]))
            elseif edge_weight_format == "FULL_MATRIX"
              edge = Edge(k + 1, i + 1, parse(Int, data[j+1]))
            else
              warn("Unknown format - function read_edges")
            end
            push!(edges, edge)
            i += 1
          end

          n_to_read -= n_on_this_line
          n_data -= n_on_this_line

          if n_to_read <= 0
            start += n_on_this_line
            k += 1
            i = 0
            n_to_read = n_nodes_to_read(edge_weight_format, k, dim)
          end

          if k >= dim
            n_data = 0
            flag = true
          end
        end
      end
    end
  end
  close(file)
  return edges
end

"""Renvoie les noeuds et les arêtes du graphe."""
function read_stsp(filename::String; quiet::Bool=true)
  !quiet && Base.print("Reading of header : ")
  header = read_header(filename)
  !quiet && println("✓")
  dim = parse(Int, header["DIMENSION"])
  edge_weight_format = header["EDGE_WEIGHT_FORMAT"]

  !quiet && Base.print("Reading of nodes : ")
  graph_nodes = read_nodes(header, filename)
  !quiet && println("✓")

  !quiet && Base.print("Reading of edges : ")
  graph_edges = read_edges(header, filename)
  """
  for edge in edges_brut
    if edge_weight_format in ["UPPER_ROW", "LOWER_COL", "UPPER_DIAG_ROW", "LOWER_DIAG_COL"]
      push!(graph_edges[edge[1]], edge[2])
    else
      push!(graph_edges[edge[2]], edge[1])
    end
  end
  """
  #Maxence : il va falloir figure out ce que ce truc fait je l'ai mis en commentaire pour l'instant, on le mettra dans read_edges plus tard

  !quiet && println("✓")
  return Graph(header["NAME"], graph_nodes, graph_edges)
end

"""Affiche un graphe étant donnés un ensemble de noeuds et d'arêtes.

Exemple :

    graph_nodes, graph_edges = read_stsp("bayg29.tsp")
    plot_graph(graph_nodes, graph_edges)
    savefig("bayg29.pdf")
"""
function plot_graph(nodes, edges)
  fig = plot(legend=false)

  # edge positions
  for k = 1:length(edges)
    for j in edges[k]
      plot!([nodes[k][1], nodes[j][1]], [nodes[k][2], nodes[j][2]],
        linewidth=1.5, alpha=0.75, color=:lightgray)
    end
  end

  # node positions
  xys = values(nodes)
  x = [xy[1] for xy in xys]
  y = [xy[2] for xy in xys]
  scatter!(x, y)

  fig
end

"""Fonction de commodité qui lit un fichier stsp et trace le graphe."""
function plot_graph(filename::String)
  graph_nodes, graph_edges = read_stsp(filename)
  plot_graph(graph_nodes, graph_edges)
end