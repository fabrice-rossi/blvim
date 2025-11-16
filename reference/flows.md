# Extract the flow matrix from a spatial interaction model object

Extract the flow matrix from a spatial interaction model object

## Usage

``` r
flows(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object

- ...:

  additional parameters

## Value

a matrix of flows between origin locations and destination locations

## See also

[`flows_df()`](https://fabrice-rossi.github.io/blvim/reference/flows_df.md)
for a data frame version of the flows,
[`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md)
for destination flows.

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- log(french_cities$population[1:10])
attractiveness <- log(french_cities$area[1:10])
## rescale to production
attractiveness <- attractiveness / sum(attractiveness) * sum(production)
model <- static_blvim(distances, production, 1.5, 1 / 500, attractiveness)
flows(model)
#>           75056     13055     69123     31555     06088     44109     34172
#> 75056 4.0969692 1.1088098 1.2217612 1.0921179 0.5632478 1.6240133 0.7378889
#> 13055 0.7071741 4.2253002 1.3428003 1.5342674 1.9561224 0.3929341 1.9234560
#> 69123 1.3143837 2.2647413 2.5217377 1.1758690 1.1504320 0.7218590 1.4741448
#> 31555 0.8712958 1.9235243 0.8733871 3.5073682 0.9771023 0.8927507 1.6940382
#> 06088 0.5849998 3.2232558 1.1108126 1.2692013 3.3461291 0.3250493 1.5911523
#> 44109 1.9685175 0.7507590 0.8127451 1.3602679 0.3813668 3.6122313 0.6611897
#> 34172 0.6718017 2.7488355 1.2481243 1.9264583 1.3963398 0.4933762 2.4319934
#> 67482 1.7123966 1.1773743 1.3023122 0.6776466 0.5980768 0.6912986 0.7663658
#> 33063 1.1146105 1.2519543 0.8983174 2.2683621 0.6359615 1.5194761 1.1025898
#> 59350 2.8982762 0.7759918 0.8550398 0.7730969 0.3941844 1.1496191 0.5051015
#>           67482     33063     59350
#> 75056 1.3863096 0.9779127 1.7549224
#> 13055 0.6027795 0.7007471 0.2989262
#> 69123 1.1368049 0.8475020 0.5555970
#> 31555 0.4418368 1.5921056 0.3720533
#> 06088 0.4986410 0.5796833 0.2472826
#> 44109 0.6772168 1.6269221 0.8405797
#> 34172 0.5602798 0.8798728 0.2778500
#> 67482 4.1426973 0.5088312 1.0065126
#> 33063 0.4724853 2.7490133 0.4759517
#> 59350 1.3462538 0.6922524 2.9931259
```
