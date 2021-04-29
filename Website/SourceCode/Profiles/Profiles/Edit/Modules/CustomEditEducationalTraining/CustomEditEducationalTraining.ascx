<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CustomEditEducationalTraining.ascx.cs" Inherits="Profiles.Edit.Modules.CustomEditEducationalTraining.CustomEditEducationalTraining" %>
<%@ Register TagName="Options" TagPrefix="security" Src="~/Edit/Modules/SecurityOptions/SecurityOptions.ascx" %>
<asp:UpdatePanel ID="upnlEditSection" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
          <asp:UpdateProgress ID="updateProgress" runat="server" DynamicLayout="true" DisplayAfter="1000">
            <ProgressTemplate>
                <div class="modalupdate">
                    <div class="modalcenter">
                        <img alt="Updating..." src="<%=Profiles.Framework.Utilities.Root.Domain%>/edit/images/loader.gif" />
                        <br />
                        <i>Updating...</i>
                    </div>
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
        <asp:HiddenField ID="hiddenSubjectID" runat="server" />
        <div class="editBackLink">
            <asp:Literal runat="server" ID="litBackLink"></asp:Literal>
        </div>
        <asp:Panel runat="server" ID="pnlSecurityOptions">
            <security:Options runat="server" ID="securityOptions"></security:Options>
        </asp:Panel>
        <asp:Panel ID="pnlInsertEducationalTraining" runat="server" CssClass="EditPanel" Visible="false">
            <div style="display: inline-flex;">
                <div>
                    <div style="font-weight: bold;">Institution</div>
                    <asp:TextBox ID="txtInstitution" runat="server" MaxLength="100" Width="190px" />
                </div>
                <div style="margin-left: 10px;">
                    <div style="font-weight: bold;">Location</div>
                    <asp:TextBox ID="txtLocation" runat="server" MaxLength="100" Width="130px" />
                </div>
                <div style="margin-left: 10px;">
                    <div style="font-weight: bold;">Degree (if applicable)</div>
                    <asp:TextBox ID="txtEducationalTrainingDegree" runat="server" MaxLength="100" Width="55px" />
                </div>
                <div style="margin-left: 10px;">
                    <div style="font-weight: bold;">Completion Date (MM/YYYY)</div>
                    <asp:TextBox ID="txtEndYear" runat="server" MaxLength="7" Width="80px" />
                </div>
                <div style="margin-left: 20px;">
                    <div style="font-weight: bold;">Field Of Study</div>
                    <asp:TextBox ID="txtFieldOfStudy" runat="server" MaxLength="100" Width="175px" />
                </div>
            </div>
        </asp:Panel>
        <div class="editPage">
            <asp:GridView ID="GridViewEducation" runat="server" AutoGenerateColumns="False" DataKeyNames="SubjectURI,Predicate, Object" GridLines="Both"
                 OnRowDataBound="GridViewEducation_RowDataBound"
                CssClass="editBody">
                <HeaderStyle CssClass="topRow" />
                <Columns>
                    <asp:TemplateField HeaderText="Institution" ItemStyle-CssClass="alignLeft" HeaderStyle-CssClass="alignLeft">
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEducationalTrainingInst" runat="server" MaxLength="100" Width="250px" Text='<%# Bind("Institution") %>'/>
                            <asp:HiddenField runat="server" ID="hdURI" />
                        </EditItemTemplate>
                        <ItemTemplate>
                            <asp:Label ID="Label5" runat="server" Text='<%# Bind("Institution") %>'></asp:Label>
                            <asp:HiddenField runat="server" ID="hdURI" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Location" HeaderStyle-CssClass="alignLeft" ItemStyle-CssClass="alignLeft">
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEducationalTrainingLocation" runat="server" MaxLength="100" Text='<%# Bind("Location") %>'/>
                        </EditItemTemplate>
                        <ItemTemplate>
                            <asp:Label ID="Label6" runat="server" Text='<%# Bind("Location") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Degree" HeaderStyle-CssClass="alignLeft" ItemStyle-CssClass="alignLeft">
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEducationalTrainingDegree" runat="server" Width="55px" MaxLength="100" Text='<%# Bind("Degree") %>'/>
                        </EditItemTemplate>
                        <ItemTemplate>
                            <asp:Label ID="Label3" runat="server" Text='<%# Bind("Degree") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Completion Date" HeaderStyle-CssClass="alignLeft" ItemStyle-CssClass="alignLeft">
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEndDate" runat="server" MaxLength="7" Width="70px" Text='<%# Bind("EndDate") %>'/>
                        </EditItemTemplate>
                        <ItemTemplate>
                            <asp:Label ID="Label2" runat="server" Text='<%# Bind("EndDate") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Field of Study" HeaderStyle-CssClass="alignLeft" ItemStyle-CssClass="alignLeft">
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEducationalTrainingFieldOfStudy" runat="server" MaxLength="100" Text='<%# Bind("FieldOfStudy") %>'/>
                        </EditItemTemplate>
                        <ItemTemplate>
                            <asp:Label ID="Label4" runat="server" Text='<%# Bind("FieldOfStudy") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <div class="editBody">
                Note:  Education and training data comes from an automatic data feed from Human Resources.
                <asp:Label runat="server" ID="lblNoEducation" Text="No education or training has been added." Visible="false"></asp:Label>
            </div>
    </ContentTemplate>
</asp:UpdatePanel>
