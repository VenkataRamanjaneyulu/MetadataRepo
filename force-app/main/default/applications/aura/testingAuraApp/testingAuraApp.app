<aura:application extends="force:slds">
    <aura:attribute name="options" type="List" default="[{'label':'Bob','value':'123'},
                                                         {'label':'Chrissey','value':'345'},
                                                         {'label':'Jessica','value':'456','disabled': true},
                                                         {'label':'Sunny','value':'567'}]" />
    <aura:attribute name="selectedValue" type="String" default="" description="Selected value in single Select" />
 
    <c:comboboxWithSearch options="{!v.options}" selectedValue="{!v.selectedValue}" label="Single Select Combobox"></c:comboboxWithSearch>
</aura:application>