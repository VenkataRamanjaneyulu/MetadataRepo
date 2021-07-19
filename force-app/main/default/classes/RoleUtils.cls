public class RoleUtils {
 
    public static boolean isFirstCall = true;
    public static List<UserRole> roles = new List<UserRole>();
 
    public static List<UserRole> getChildRoles(List<UserRole> userRoles){
        // add top most role to the rolesList
        if (isFirstCall){
            isFirstCall = false;
            roles.addAll(userRoles);
        }
        Set<Id> roleIds = new Set<Id>();
        for (UserRole ur: userRoles){
            roleIds.add(ur.Id);
        }

        List<UserRole> childRoles = [SELECT Id, Name, ParentRoleId FROM UserRole WHERE ParentRoleId =: roleIds];
        roles.addAll(childRoles);
        
        if (childRoles.size() > 0){
            // recursively call the same method to fetch all the child roles until no further
            // child roles are returned back
            getChildRoles(childRoles);
        }
        return roles;
 }

    public static List<RoleInfo> getChildRoles(Id parentId, List<UserRole> roles){
        List<RoleInfo> childRoles = new List<RoleInfo>();
        for(UserRole role: roles){
            if(parentId == role.ParentRoleId) {
                // recursively call the same method to form a n-th level deep hierarchy
                childRoles.add(new RoleInfo(role.Id, role.Name, role.Name, getChildRoles(role.Id, roles)));
                // sort alphabetically
                childRoles.sort();
            }
        }
        return childRoles;
    }
}