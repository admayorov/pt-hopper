package ptv

import "fmt"

type RouteType struct {
	asAPIint     int
	asGTFSstring string
}

var (
	Train        = RouteType{0, "metro"}
	Tram         = RouteType{1, "tram"}
	Bus          = RouteType{2, "bus"}
	VLine        = RouteType{3, "vline"}
	AnyRouteType = RouteType{-1, "any"}
)

var routeTypes = []RouteType{Train, Tram, Bus, VLine, AnyRouteType}

func GetRouteTypeFromGTFS(gtfsString string) (*RouteType, error) {
	for _, route := range routeTypes {
		if route.asGTFSstring == gtfsString {
			return &route, nil
		}
	}
	return nil, fmt.Errorf("provided string %s does not match any route types", gtfsString)
}
