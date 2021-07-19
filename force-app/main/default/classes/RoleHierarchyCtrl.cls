public class RoleHierarchyCtrl {
 
    @AuraEnabled(cacheable=true)
    public static String getRoles(){
        // get the top most role of the org - The top Role will have the field
        // value of ParentRoleId as null
        // This query will always return 1 record
        List<UserRole> topRole = [SELECT Id, Name, ParentRoleId FROM
                                    UserRole WHERE ParentRoleId = ''];
        // Get all the roles which are present under this parent role recursively
        // This is a flat list of all the roles present in the org
        List<UserRole> allRoles = RoleUtils.getChildRoles(topRole);

        Map<Id,List<RoleInfo>> parentToChildRolesMap = new Map<Id,List<RoleInfo>>();
        for(UserRole role: allRoles) {
            parentToChildRolesMap.put(role.Id, RoleUtils.getChildRoles(role.Id, allRoles));
        }
        List<RoleInfo> roleInfoList = new List<RoleInfo>();
        roleInfoList.add(new RoleInfo(topRole[0].Id, topRole[0].Name,
                            topRole[0].Name, parentToChildRolesMap.get(topRole[0].Id)));
                            
        return JSON.serialize(roleInfoList, true);
    }
}