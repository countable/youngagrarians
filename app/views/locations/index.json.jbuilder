json.array! @locations do |location|
  json.id location.id
  json.name location.name

  json.latitude location.latitude
  json.longitude location.longitude
  json.bioregion location.bioregion
  json.city  location.city
  json.country location.country
  json.province location.province
  json.streetAddress location.street_address
  json.hasGoogleMap location.gmaps
  json.postalCode location.postal

  json.facebookUrl location.fb_url
  json.twitterUrl location.twitter_url

  json.content location.content
  json.description location.description

  json.owner nil
  
  json.created location.created_at
  json.updated location.updated_at

  json.url location.url
  json.resourceType location.resource_type
end
