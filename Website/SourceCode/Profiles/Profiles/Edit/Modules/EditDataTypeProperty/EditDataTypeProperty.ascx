﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="EditDataTypeProperty.ascx.cs"
    Inherits="Profiles.Edit.Modules.EditDataTypeProperty.EditDataTypeProperty" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<%@ Register TagName="Options" TagPrefix="security" Src="~/Edit/Modules/SecurityOptions/SecurityOptions.ascx" %>

<script type="text/javascript" src="//code.jquery.com/jquery-3.3.1.min.js"></script>
<script type="text/javascript">

    /* Names of the links provided in the GridView */
    var cancelLink = 'lnkCancel';
    var editLink = 'lnkEdit';
    var editProperty = 'btnEditProperty';
    
    /* Add function that will fire after ajax request completes on the page */
    $(document).ready(function() {
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(endRequestHandler);
    });

    function endRequestHandler(sender, args) {

        /* Edit Button on row clicked */
        if ( sender._postBackSettings.sourceElement.id.endsWith(editLink) )
        {
            initEditor();
        }

        /* Initial Add */
        if ( sender._postBackSettings.sourceElement.id.endsWith(editProperty) ) {
            initEditor();
        }

        /* Cancel clicked */
        if (sender._postBackSettings.sourceElement.id.endsWith(cancelLink)) {
        }
    }

    function initEditor()
    {
        /* Remove any existing instances of the editor */
        tinymce.EditorManager.remove('div.editableHtmlContainer');

        /* Give the removal just a fraction of a second to run before we re-init the editor */
        setTimeout(function () {
            tinymce.init({
                selector: 'div.editableHtmlContainer',
                inline: true,
                menubar: false,
                fixed_toolbar_container: '.tinymceToolbar',
                plugins: 'paste lists link image print preview table media<%= getHTMLEditorConfigurablePluginsOptions() %>',
                toolbar1: 'undo redo | styleselect | bold italic underline | alignleft aligncenter alignright alignjustify | indent outdent | bullist numlist',
                toolbar2: 'link image | print preview | table<%= getHTMLEditorConfigurableToolbarOptions() %>',
                paste_word_valid_elements: "b,strong,i,em,h1,h2,h3,p,ol,ul,li",
                paste_retain_style_properties: "color font-size", 
                content_css: '/Framework/CSS/profiles.css',
                init_instance_callback: function (editor) {
                    //Set focus on editor so toolbar appears
                    editor.fire('focus');
                },
                setup: function (editor) {
                    //Store content in hidden input for update and stop blur to keep toolbar appearing
                    editor.on('blur', function (e) {
                        $('[id*=NewContentHidden]').val(editor.getContent());
                        return false;
                    });
                },
                file_picker_callback: function (callback, value, meta) {
                    if (meta.filetype == 'image' || meta.filetype == 'media') {
                        //Get file/image upload configuration; return on none set
                        var storageURL = meta.filetype == 'image' ? '<%=getConfigSetting("ProfilesImageStorageURL")%>' : '<%=getConfigSetting("ProfilesFileStorageURL")%>';
                        var storageName = '<%=getConfigSetting("ProfilesImageStorageName")%>';
                        if (!storageURL || !storageName)
                        {
                            return;
                        }

                        var input = document.createElement('input');
                        input.setAttribute('type', 'file');
                        input.onchange = function() {
                            var file = this.files[0];
                            var reader = new FileReader();
                            reader.onload = function () {
                                //Hide form and show progress indicator
                                $('.mce-form').hide();
                                $('.mce-form').parent().append('<div class="uploadInProgress mce-container" style="margin-top: 62px;text-align: center;"><label class="mce-label">File upload in progress...</label></div>');

                                // Register the blob in TinyMCEs image blob registry
                                var id = 'profilesOverview' + (new Date()).getTime();
                                var blobCache =  tinymce.activeEditor.editorUpload.blobCache;
                                var base64 = reader.result.split(',')[1];
                                var blobInfo = blobCache.create(id, file, base64);
                                blobCache.add(blobInfo);

                                //Upload to cloud storage in subject's container with filename prefixed to prevent overwritting
                                var subjectID = '<%= SubjectID %>';
                                var fileName = id + '_' + file.name;
                                var requestBody = JSON.stringify({
                                        "StorageAccount": storageName,
                                        "ContainerName": subjectID,
                                        "FileName": fileName,
                                        "File": base64
                                    });
                                $.ajax({
                                    url: storageURL,
                                    method: 'POST',
                                    contentType: 'application/json',
                                    crossDomain: true,
                                    data: requestBody,
                                    dataType: 'json',
                                    complete: function () {
                                        //Remove progress indicator, show form
                                        $('.uploadInProgress').remove();
                                        $('.mce-form').show();
                                    },
                                    success: function (response, textStatus, jQxhr) {
                                        //Disable source input
                                        $('.mce-filepicker > input').prop('disabled', true);
                                        $('.mce-filepicker > input').css('background', '#c5c5c5');

                                        //Callback with URL to large copy of photo in cloud storage; populate the Title field with the file name
                                        callback(response["Large"], { title: file.name });
                                    },
                                    error: function (jqXhr, textStatus, error) {
                                        tinymce.activeEditor.windowManager.alert("An error occurred while uploading the image.");
                                    }
                                });
                            };
                            reader.readAsDataURL(file);
                        };
                        input.click();
                    }
                },
            });
        }, 10);
    }

    function beforePostback()
    {
        tinymce.triggerSave();
    }

</script>


<table width="100%">
    <tr>
        <td align="left" style="padding-right: 12px">
            <asp:Literal runat="server" ID="litBackLink"></asp:Literal>
        </td>
    </tr>
</table>
<asp:UpdatePanel ID="upnlEditSection" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:HiddenField ID="hiddenSubjectID" runat="server" />
        <asp:UpdateProgress ID="updateProgress" runat="server">
            <ProgressTemplate>
                <div style="position: fixed; text-align: center; height: 100px; width: 100px; top: 0;
                    right: 0; left: 0; z-index: 9999999; opacity: 0.7;">
                    <span style="border-width: 0px; position: fixed; padding: 50px; background-color: #FFFFFF;
                       font-size: 25px; left: 40%; top: 40%;"><img alt="Loading..." src="../edit/Images/loader.gif" /></span>
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
        <table id="tblEditProperty" width="100%">
            <tr>
                <td colspan='3'>
                    <asp:Literal runat="server" ID="Literal1"></asp:Literal>                    
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    <div style="padding: 10px 0px;">
                        <security:Options runat="server" ID="securityOptions"></security:Options>
                        <br />
                        <asp:LinkButton ID="btnEditProperty" runat="server" CommandArgument="Show" OnClick="btnEditProperty_OnClick"
                            CssClass="profileHypLinks">
                            <asp:Image runat="server" ID="imbAddArror" AlternateText=" " ImageUrl="~/Framework/Images/icon_squareArrow.gif"/>&nbsp;
                            <asp:Literal runat="server" ID="litEditProperty">Add Property</asp:Literal>                           
                        </asp:LinkButton>
                    </div>
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    <asp:Repeater ID="RptrEditProperty" runat="server" Visible="false">
                        <ItemTemplate>
                            <asp:Label ID="lblEditProperty" runat="server" Text='<%#Eval("Label").ToString() %>' />
                            <br />
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="pnlInsertProperty" runat="server" Style="background-color: #F0F4F6;
                        margin-bottom: 5px; border: solid 1px #ccc;" 
                        Visible="false">
                        <table border="0" cellspacing="2" cellpadding="4">
                            <tr>
                                <td width="750">
                                    <div class="tinymceToolbar"></div>
                                    <asp:Panel ID="insertPropertyDiv" runat="server" CssClass="editableHtmlContainer"></asp:Panel>
                                    <asp:HiddenField ID="insertNewContentHidden" runat="server"></asp:HiddenField>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="3">
                                    <div style="padding-bottom: 5px; text-align: left;">
                                        <asp:LinkButton ID="btnInsertProperty" runat="server" CausesValidation="False" OnClick="btnInsert_OnClick"
                                            Text="Save and add another&nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;" ></asp:LinkButton>                                        
                                        <asp:LinkButton ID="btnInsertProperty2" runat="server" CausesValidation="False" OnClick="btnInsertClose_OnClick"
                                            Text="Save and Close" ></asp:LinkButton>
                                        &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                                        <asp:LinkButton ID="btnInsertCancel" runat="server" CausesValidation="False" OnClick="btnInsertCancel_OnClick"
                                            Text="Close" ></asp:LinkButton>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </asp:Panel>
                    <div style="border-left: solid 1px #ccc;">
                        <asp:GridView ID="GridViewProperty" runat="server" AutoGenerateColumns="False" CellPadding="4"
                            DataKeyNames="Subject,Predicate, Object" OnRowCancelingEdit="GridViewProperty_RowCancelingEdit"
                            OnRowDataBound="GridViewProperty_RowDataBound" OnRowDeleting="GridViewProperty_RowDeleting"
                            OnRowEditing="GridViewProperty_RowEditing" OnRowUpdated="GridViewProperty_RowUpdated"
                            OnRowUpdating="GridViewProperty_RowUpdating" Width="100%">
                            <HeaderStyle CssClass="topRow" BorderStyle="Solid" BorderWidth="1px" />
                            <RowStyle CssClass="edittable" />
                            <Columns>
                                <asp:TemplateField HeaderText="">
                                    <EditItemTemplate>
                                        <div class="tinymceToolbar"></div>
                                        <asp:Panel ID="editableDiv" runat="server" CssClass="editableHtmlContainer">
                                            <asp:Literal ID="editableLiteral" runat="server" Text='<%# Bind("Literal") %>'></asp:Literal>
                                        </asp:Panel>
                                        <asp:HiddenField ID="editNewContentHidden" runat="server"></asp:HiddenField>
                                        <asp:HiddenField ID="oldContentHidden" runat="server" Value='<%# Bind("Literal") %>'></asp:HiddenField>
                                    </EditItemTemplate>
                                    <ItemTemplate>
                                        <asp:Label ID="lblLabel" runat="server"></asp:Label>
                                    </ItemTemplate>
                                    <ControlStyle Width="600px" />
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                                  <asp:TemplateField ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" HeaderText="Action" ItemStyle-VerticalAlign="Top"
                                    ShowHeader="False">
                                    <EditItemTemplate>
                                        <table class="actionbuttons">
                                            <tr>
                                                <td>
                                                    <asp:ImageButton ID="lnkUpdate" runat="server" ImageUrl="~/Edit/Images/button_save.gif"
                                                        CausesValidation="True" CommandName="Update" Text="Update" AlternateText="Update"></asp:ImageButton>
                                                </td>
                                                <td>
                                                    <asp:ImageButton ID="lnkCancel" runat="server" ImageUrl="~/Edit/Images/button_cancel.gif"
                                                        CausesValidation="False" CommandName="Cancel" Text="Cancel" AlternateText="Cancel"></asp:ImageButton>
                                                </td>
                                            </tr>
                                        </table>
                                    </EditItemTemplate>
                                    <ItemTemplate>
                                    </ItemTemplate>
                                    <ItemTemplate>
                                        <div class="actionbuttons">
                                            <table>
                                                <tr>
                                                    <td>
                                                        <asp:ImageButton OnClick="ibUp_Click" runat="server" CommandArgument="up" CommandName="action"
                                                            ID="ibUp" ImageUrl="~/Edit/Images/icon_up.gif" AlternateText="move up"/>
                                                    </td>
                                                    <td>
                                                        <asp:ImageButton runat="server" OnClick="ibDown_Click" ID="ibDown" CommandArgument="down"
                                                            CommandName="action" ImageUrl="~/Edit/Images/icon_down.gif" AlternateText="move down" />
                                                    </td>
                                                    <td>
                                                        <asp:ImageButton ID="lnkEdit" runat="server" ImageUrl="~/Edit/Images/icon_edit.gif"
                                                            CausesValidation="False" CommandName="Edit" Text="Edit" AlternateText="Edit"></asp:ImageButton>
                                                    </td>
                                                    <td>
                                                        <asp:ImageButton ID="lnkDelete" runat="server" ImageUrl="~/Edit/Images/icon_delete.gif"
                                                            CausesValidation="False" CommandName="Delete" OnClientClick="Javascript:return confirm('Are you sure you want to delete this entry?');"
                                                            Text="X" AlternateText="delete"></asp:ImageButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                    <asp:Label runat="server" ID="lblNoItems" Text="<i>No items have been added.</i>" Visible = "false"></asp:Label>
                </td>
            </tr>
        </table>
    </ContentTemplate>
</asp:UpdatePanel>


