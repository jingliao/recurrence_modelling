#################### Header Start ####################
# Title : a proof-of-concept network theory applied to episode resolution
# Author: Jing Liao
# Date created : 22/03/2026
# Date modified: 26/04/2026
#################### Header End   ####################

# synthetic data

events <- tibble(id = c(rep(1, 4), rep(2, 2)),
                 source = c("S1", "S2", "S3", "S2", "S1", "S3"),
                 event_id = c("A1", "B1", "C1", "B2", "A2", "C2"),
                 start = ymd(c("2025-06-01", "2025-06-05", "2025-06-06",
                               "2025-07-15", "2025-06-03", "2025-06-04")),
                 end = ymd(c("2025-06-10", "2025-06-05", "2025-06-06",
                             "2025-07-15", "2025-06-05", "2025-06-04")),
                 flag1 = c(rep(1, 2), rep(0, 2), rep(1, 2)),
                 flag2 = c(rep(0, 2), 1, rep(0, 3))
                 ) |>
  mutate(event_key = row_number()
         )

# define time window of events flew between any two sources

rules <- tibble(source.x = c("S1", "S2", "S1", "S3", "S2", "S3", "S1", "S2", "S3"),
                source.y = c("S2", "S1", "S3", "S1", "S3", "S2", "S1", "S2", "S3"),
                max_gap_days = c(7, 7, 3, 3, 1, 1, 0, 0, 0)
                )

# pair events with time window, and identify overlaps

event_pairs <- events |>
  inner_join(events,
             by = "id",
             suffix = c(".x", ".y"),
             relationship = "many-to-many") |>
  # clean duplicated data and keep x < y
  filter(event_key.x < event_key.y) |>
  # identify overlaps and calculate gap day
  mutate(overlap_raw = pmax(start.x, start.y) <= pmin(end.x, end.y),
         gap_days = if_else(overlap_raw, 0, as.numeric(pmax(start.x, start.y) - pmin(end.x, end.y)))
         )

# decide connection

event_pairs_connect <- event_pairs |>
  left_join(rules,
            by = c("source.x", "source.y")
            ) |>
  mutate(connect = !is.na(max_gap_days) & gap_days <= max_gap_days)

event_pairs_connect |>
  dplyr::select(id, event_id.x, source.x, start.x, end.x,
                event_id.y, source.y, start.y, end.y,
                gap_days, max_gap_days, connect)

# buildf up a graph using connect

edges <- event_pairs_connect |>
  filter(connect) |>
  transmute(from = event_key.x,
            to = event_key.y)

g <- graph_from_data_frame(d = edges,
                           directed = FALSE,
                           vertices = events |>
                             dplyr::select(event_key,
                                           id,
                                           source,
                                           event_id,
                                           start,
                                           end,
                                           flag1,
                                           flag2)
                           )

comp <- components(g)

# fill up events using episodes

events_with_ep <- events |>
  mutate(episode_id = comp$membership[as.character(event_key)]) |>
  arrange(id,
          episode_id,
          start)

# summarise episode

ep_summary <- events_with_ep |>
  group_by(id, episode_id) |>
  summarise(person_id = dplyr::first(id),
            episode_start = min(start),
            episode_end = max(end),
            sources = paste(sort(unique(source)), collapse = "+"),
            n_events = dplyr::n(),
            any_flag1 = as.integer(any(flag1 == 1, na.rm = TRUE)),
            any_flag2 = as.integer(any(flag2 == 2, na.rm = TRUE)),
            events = paste(paste(source, event_id, sep = ":"),
                           collapse = ", "),
            .groups = "drop") |>
  arrange(id, episode_start)

ep_summary

# visualisation

transitions <- ep_summary |>
  arrange(person_id, 
          episode_start) |>
  group_by(person_id) |>
  arrange(episode_start,
          .by_group = TRUE) |>
  mutate(source_from = lag(sources),
         source_to = sources) |>
  ungroup() |>
  filter(!is.na(source_from)
         )

transition_counts <- transitions |>
  dplyr::count(source_from, source_to, name = "n") |>
  bind_rows(data.frame(source_from = c("S1", "S2", "S1", "S1+S2", "S1+S2"),
                       source_to = c("S1", "S1+S2", "S2", "S2", "S1"),
                       n = c(120, 45, 32, 52, 29))
  )

transition_probs <- transition_counts |>
  group_by(source_from) |>
  mutate(p = n / sum(n)) |>
  ungroup()

g <- graph_from_data_frame(d = transition_probs |>
                             transmute(from = source_from,
                                       to = source_to,
                                       weight = p),
                           directed = TRUE)

set.seed(123)

plot(g,
     edge.width = E(g)$weight*8,
     edge.label = round(E(g)$weight, 2),
     vertex.size = 30,
     vertex.label.cex = 1.2)

p <- recordPlot()

invisible(p)