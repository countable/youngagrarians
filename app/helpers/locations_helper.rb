module LocationsHelper
  # ------------------------------------------------------- agriculature_options
  def agriculture_options
    ['Vegetable', 'Livestock', 'Grain', 'Seed', 'Hay & Forage', 'Orchard/Fruit', 'Mixed', 'Other']
  end
  # --------------------------------------------------- agriculture_type_options
  def agriculture_type_options
    ['Certified Organic', 'Organic', 'Conventional']
  end

  def training_options
    ['Agriculture-related degree', 'Farm management (3 years or less)',
      'Farm management (3 years+)', 'Apprenticeship', 'General degree', 'General farming (3 years or less)',
      'General farming (3 years+)', 'Other experience/agricultural/business training']
  end

  # ----------------------------------------------------------------- bc_regions
  def bc_regions
    [ 'Any', 'Cariboo – Upper Fraser', 'Skeena – North Coast', 'Lower Mainland - Fraser Valley',
      'Thompson - Okanagan', 'Kootenays', 'Vancouver Island', 'Northeast']
  end
  # ----------------------------------------------------------- category_options
  def category_options( location, category = nil )
    # inefficient!
    category ||= NestedCategory.find( location.primary_category_id )
    @cateogry_options_list ||= build_list( category.parent, true )
    options_for_select( @cateogry_options_list.map{ |x| [ x.parent ? format( '%s > %s', x.parent.name, x.name ) : x.name, x.id] }, category.id )
  end
  # ------------------------------------------------------------------ is_admin?
  def is_admin?
    session[:admin_user_id]
    #@location.is_admin?( current_user ) || current_admin_user
  end
  # ----------------------------------------------------------------- build_list
  def build_list( c, skip_self = false )
    kids = c.children.map{ |x| build_list( x ) }.flatten
    skip_self ? kids : [c] + kids
  end
  # ------------------------------------------------------------ display_address
  def display_address( location )
    r_val = ''.html_safe
    if @location.street_address.present?
      r_val << h( @location.street_address ) 
      r_val << tag( 'br' )
    end
    if @location.city.present? && @location.province.present?
      r_val << format( '%s, %s', h( @location.city ), h( @location.province ) ).html_safe
    elsif @location.city.present?
      r_val << h( @location.city )
    elsif @location.province.present?
      r_val << h( @location.province )
    end
    if @location.postal.present?
      r_val << h( ", " + @location.postal )
    end
    r_val << tag('br' ) if @location.city.present? || @location.province.present?
    r_val << @location.country if @location.country.present?
    return r_val
  end

  # ---------------------------------------------------------- top_category_list
  def top_category_list( location )
    metas = location.nested_categories
                    .joins( "LEFT OUTER JOIN nested_categories parent ON nested_categories.parent_category_id = parent.id" )
                    .pluck( 'COALESCE( parent.name, nested_categories.name ) AS name',
                            'COALESCE( parent.id, nested_categories.id ) as x' )
    if metas.any?
      content_tag( 'ul', class: 'top_category_list' ) do 
        links = metas.map do |category_name, category_id|
          content_tag( 'li', link_to( category_name,
                             meta_category_path( top_level_name: category_name ),
                             class: "filled" ),
                          class: "category_#{category_id} #{category_name.downcase.gsub(/[^a-zA-Z]/,'-')}"
                          )
        end
        safe_join( links, '' )

      end
    else
      nil
    end
  end


  # ---------------------------------------------------------- top_category_list
  def category_list( location )
    content_tag( 'ul', class: 'top_category_list' ) do
      cats = location.nested_categories.map do |rec|
        content_tag( 'li', link_to( rec.name,
                           meta_category_path( top_level_name: rec.name ),
                           class: "filled" ),
                        class: "#{rec.name.downcase.gsub(/[^a-zA-Z]/,'-')}"
                        )
      end
      safe_join( cats, '' )
    end
  end

  # ---------------------------------------------------------- top_category_list
  def category_class( location )
    # TODO: slow and inefficient
    @category_class_list ||= {}
    @category_class_list[location.id] ||= begin
      r_val = []
      location.nested_categories.each do |category|
        loop do
          break if category.nil?
          if category.parent && category.parent.parent.nil?
            r_val << category.name.gsub( /[^a-zA-Z]/, '-' )
            break
          end
          category = category.parent
        end
      end
      if r_val.any?
        r_val[0].downcase
      else
        nil
      end
    end
  end

  def smart_add_url_protocol( url )
    
    if url and url.length > 0 and not url[/^https?:\/\//]
      "http://#{url}"
    else
      url
    end
  end

  # -------------------------------------------------------------- contact_links
  def contact_links( location )
    labels = {:url => 'Url', :fb_url => 'Facebook', :twitter_url => 'Twitter'}
    content_tag( 'div', class: 'links' ) do
      r_val = ''.html_safe
      [:url, :fb_url, :twitter_url ].each do |link_type|
        l = smart_add_url_protocol( location.send( link_type ) )
        if l.present?
          r_val << content_tag('b') do
            "#{labels[link_type]}: "
          end

          r_val << link_to( l, l, class: link_type, target: '_blank' )
          r_val << tag( 'br' )
        end
      end
      r_val
    end
  end

  def lf_bool_with_comment( location, field_name )
    r_val = ''.html_safe

    field_val = location.send(field_name)

    if field_val

      if field_val.instance_of? String
        # This should actually not happen... TODO: find out why it does for new seeker listings?
        r_val << field_val
      else
        if field_val.true?
          r_val << 'Yes'
        else
          r_val << 'No'
        end
        if field_val.comment.present?
          r_val << content_tag( 'span' ) do
            ' - ' + field_val.comment
          end
        end
      end
    else
      r_val << '(unspecified)'
    end
    r_val
  end

  def lf_multiselect( location, field_name )
    content_tag( 'ul' ) do
      r_val = ''.html_safe
      location.send(field_name).each do |use|
        if use['chosen']
          r_val << content_tag( 'li' ) do
            rr_val = ''.html_safe
            rr_val << use['value'] + ' - '
            rr_val << content_tag( 'span', use['comment'], class: 'comment' ) if use['comment'].present?
            rr_val
          end
        end
      end
      r_val
    end
  end

  def lf_simple( location, field_name )
    if location.send(field_name).present?
      location.send(field_name)
    end
  end

end
