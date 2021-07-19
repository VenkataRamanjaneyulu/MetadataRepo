public class RoleInfo implements Comparable{

    public Id roleId {get;set;}

    public String label {get;set;}

    public String name {get;set;}

    public List<RoleInfo> items {get;set;}

    public RoleInfo(Id roleId, String label, String name, List<RoleInfo> items){
        this.roleId = roleId;
        this.label = label;
        this.name = name;
        this.items = items;
    }

    public Integer compareTo(Object objToCompare){
        // sort alphabetically
        return name.compareTo(((RoleInfo)objToCompare).name);
    }
}