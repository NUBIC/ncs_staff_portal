##
# An ActionController that provides before_filters to:
#
# 1. loads a referenced staff record
# 2. ensures that the logged-in staff member is able to view the referenced
#    record
#
# None of the provided filters are active by default.
class StaffAuthorizedController < SecuredController
  include NcsNavigator::StaffPortal::UserLoading

  ##
  # Loads a staff object from params[:staff_id], or params[:id] if the params
  # object has no :staff_id key.  The staff object will be loaded into @staff.
  #
  # This staff object may be either a {MachineAccount} or {Staff} record.  The
  # {#assert_staff} filter may be used to prevent machine accounts from being
  # used in contexts where a {Staff} object is expected.
  #
  # If no user object can be found, returns false and aborts the request.
  def load_staff
    @staff = if params.has_key?(:staff_id)
               find_user(params[:staff_id])
             else
               find_user(params[:id])
             end

    @staff.tap { |s| render :nothing => true, :status => :not_found unless s }
  end

  ##
  # Asserts that @staff contains a {Staff} object.
  #
  # Many actions are tightly bound to the definition of {Staff}, and it doesn't
  # really make sense to decouple them from that definition.
  #
  # Actions that can use the smaller interface shared by e.g. {MachineAccount}
  # and {Staff} should skip this filter.
  def assert_staff
    unless @staff.is_a?(Staff)
      render :nothing => true, :status => :bad_request
    end
  end

  ##
  # Asserts that the current user is authorized to view the loaded staff
  # record.
  def check_requested_staff_visibility
    unless @current_staff.can_see_staff?(@staff)
      render :nothing => true, :status => :forbidden
    end
  end
end
