// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
Ext.QuickTips.init();

Ext.onReady(function(){
  // We want to build our file browsing application here to replace Simile

Ext.namespace('Ext.ux.dd');
 
Ext.ux.dd.GridDragDropRowOrder = Ext.extend(Ext.util.Observable,
{
    copy: false,
 
    scrollable: false,
 
    lockedField: 'locked',
 
    constructor : function(config)
    {
        if (config) {
            Ext.apply(this, config);
        }
 
        this.addEvents(
        {
            beforerowmove: true,
            afterrowmove: true,
            beforerowcopy: true,
            afterrowcopy: true
        });
 
       Ext.ux.dd.GridDragDropRowOrder.superclass.constructor.call(this);
    },
 
    init : function (grid)
    {
        this.grid = grid;
        grid.enableDragDrop = true;
 
        grid.on({
            render: { fn: this.onGridRender, scope: this, single: true }
        });
    },
 
    onGridRender : function (grid)
    {
        var self = this;
 
        this.target = new Ext.dd.DropTarget(grid.getEl(),
        {
            ddGroup: grid.ddGroup || 'GridDD',
            grid: grid,
            gridDropTarget: this,
 
            notifyDrop: function(dd, e, data)
            {
                // Remove drag lines. The 'if' condition prevents null error when drop occurs without dragging out of the selection area
                if (this.currentRowEl)
                {
                    this.currentRowEl.removeClass('grid-row-insert-below');
                    this.currentRowEl.removeClass('grid-row-insert-above');
                }
 
                // determine the row
                var t = Ext.lib.Event.getTarget(e);
                var rindex = this.grid.getView().findRowIndex(t);
                if (rindex === false || rindex == data.rowIndex)
                {
                    return false;
                }
 
                // fire the before move/copy event
                if (this.gridDropTarget.fireEvent(self.copy ? 'beforerowcopy' : 'beforerowmove', this.gridDropTarget, data.rowIndex, rindex, data.selections, 123) === false)
                {
                    return false;
                }
 
                // update the store
                var ds = this.grid.getStore();
 
                // Changes for multiselction by Spirit
                var selections = new Array();
                var keys = ds.data.keys;
                for (var key in keys)
                {
                    for (var i = 0; i < data.selections.length; i++)
                    {
                        if (keys[key] == data.selections[i].id)
                        {
                            // Exit to prevent drop of selected records on itself.
                            if (rindex == key)
                            {
                                return false;
                            }
                            selections.push(data.selections[i]);
                        }
                    }
                }
 
                // fix rowindex based on before/after move
                if (rindex > data.rowIndex && this.rowPosition < 0)
                {
                    rindex--;
                }
                if (rindex < data.rowIndex && this.rowPosition > 0)
                {
                    rindex++;
                }
 
                // fix rowindex for multiselection
                if (rindex > data.rowIndex && data.selections.length > 1)
                {
                    rindex = rindex - (data.selections.length - 1);
                }
 
                // we tried to move this node before the next sibling, we stay in place
                if (rindex == data.rowIndex)
                {
                    return false;
                }
 
                // fire the before move/copy event
                /* dupe - does it belong here or above???
if (this.gridDropTarget.fireEvent(self.copy ? 'beforerowcopy' : 'beforerowmove', this.gridDropTarget, data.rowIndex, rindex, data.selections, 123) === false)
{
return false;
}
*/
 
                if (!self.copy)
                {
                    for (var i = 0; i < data.selections.length; i++)
                    {
                        ds.remove(ds.getById(data.selections[i].id));
                    }
                }
 
                for (var i = selections.length - 1; i >= 0; i--)
                {
                    var insertIndex = rindex;
                    ds.insert(insertIndex, selections[i]);
                }
 
                // re-select the row(s)
                var sm = this.grid.getSelectionModel();
                if (sm)
                {
                    sm.selectRecords(data.selections);
                }
 
                // fire the after move/copy event
                this.gridDropTarget.fireEvent(self.copy ? 'afterrowcopy' : 'afterrowmove', this.gridDropTarget, data.rowIndex, rindex, data.selections);
                return true;
            },
 
            notifyOver: function(dd, e, data)
            {
                var t = Ext.lib.Event.getTarget(e);
                var rindex = this.grid.getView().findRowIndex(t);
 
                // Similar to the code in notifyDrop. Filters for selected rows and quits function if any one row matches the current selected row.
                var ds = this.grid.getStore();
                var keys = ds.data.keys;
 
                var rec = ds.getAt(rindex);
 
                if(rec && rec.get('locked')) {
                    if (this.currentRowEl)
                    {
                        this.currentRowEl.removeClass('grid-row-insert-below');
                        this.currentRowEl.removeClass('grid-row-insert-above');
                    }
                    return this.dropNotAllowed;
                }
 
                for (var key in keys)
                {
                    for (var i = 0; i < data.selections.length; i++)
                    {
                        if (keys[key] == data.selections[i].id)
                        {
                            if (rindex == key)
                            {
                                if (this.currentRowEl)
                                {
                                    this.currentRowEl.removeClass('grid-row-insert-below');
                                    this.currentRowEl.removeClass('grid-row-insert-above');
                                }
                                return this.dropNotAllowed;
                            }
                        }
                    }
                }
 
                // If on first row, remove upper line. Prevents negative index error as a result of rindex going negative.
                if (rindex < 0 || rindex === false)
                {
                    this.currentRowEl.removeClass('grid-row-insert-above');
                    return this.dropNotAllowed;
                }
 
                try
                {
                    var currentRow = this.grid.getView().getRow(rindex);
                    // Find position of row relative to page (adjusting for grid's scroll position)
                    var resolvedRow = new Ext.Element(currentRow).getY() - this.grid.getView().scroller.dom.scrollTop;
                    var rowHeight = currentRow.offsetHeight;
 
                    // Cursor relative to a row. -ve value implies cursor is above the row's middle and +ve value implues cursor is below the row's middle.
                    this.rowPosition = e.getPageY() - resolvedRow - (rowHeight/2);
 
                    // Clear drag line.
                    if (this.currentRowEl)
                    {
                        this.currentRowEl.removeClass('grid-row-insert-below');
                        this.currentRowEl.removeClass('grid-row-insert-above');
                    }
 
                    if (this.rowPosition > 0)
                    {
                        // If the pointer is on the bottom half of the row.
                        this.currentRowEl = new Ext.Element(currentRow);
                        this.currentRowEl.addClass('grid-row-insert-below');
                    }
                    else
                    {
                        // If the pointer is on the top half of the row.
                        if (rindex - 1 >= 0)
                        {
                            var previousRow = this.grid.getView().getRow(rindex - 1);
                            this.currentRowEl = new Ext.Element(previousRow);
                            this.currentRowEl.addClass('grid-row-insert-below');
                        }
                        else
                        {
                            // If the pointer is on the top half of the first row.
                            this.currentRowEl.addClass('grid-row-insert-above');
                        }
                    }
                }
                catch (err)
                {
                    WLC.debug(err);
                    rindex = false;
                }
                return (rindex === false)? this.dropNotAllowed : this.dropAllowed;
            },
 
            notifyOut: function(dd, e, data)
            {
                // Remove drag lines when pointer leaves the gridView.
                if (this.currentRowEl)
                {
                    this.currentRowEl.removeClass('grid-row-insert-above');
                    this.currentRowEl.removeClass('grid-row-insert-below');
                }
            }
        });
 
        if (this.targetCfg)
        {
            Ext.apply(this.target, this.targetCfg);
        }
 
        if (this.scrollable)
        {
            Ext.dd.ScrollManager.register(grid.getView().getEditorParent());
            grid.on({
                beforedestroy: this.onBeforeDestroy,
                scope: this,
                single: true
            });
        }
    },
 
    getTarget: function()
    {
        return this.target;
    },
 
    getGrid: function()
    {
        return this.grid;
    },
 
    getCopy: function()
    {
        return this.copy ? true : false;
    },
 
    setCopy: function(b)
    {
        this.copy = b ? true : false;
    },
 
    onBeforeDestroy : function (grid)
    {
        // if we previously registered with the scroll manager, unregister
        // it (if we don't it will lead to problems in IE)
        Ext.dd.ScrollManager.unregister(grid.getView().getEditorParent());
    }
});

  Ext.namespace('Locker');

  Ext.namespace('Locker.ux');

  Locker.ux.FileUploadWindow = Ext.extend(Ext.Window, {
    store: null,
    title: 'Upload File',
    renderTo: document.body,
    url_base: '',
    form_authenticity_token: null,
    tools: [{
      id: 'close',
      handler: function(e,toolEl,panel,tc) {
        panel.destroy();
      }
    }],
    
    constructor: function(config)
    {   
      var group_store;

        if (config) {

    config.groups.filterBy(function(rec, id ) { return rec.get("members_can_contribute"); });
    groups = [ ];
    config.groups.getRange().each(function(rec) {
      groups.push([rec.get("id"), rec.get("name")])
    });

    config.items = [{
      xtype: 'form',
      buttonAlign: 'center',
      margins: {
        left: 5,
        top: 5
      },
      width: 500,
      buttons: [{
        text: 'Upload File',
        type: 'submit',
        handler: function(f) {
          var fp = this.ownerCt.ownerCt;
  
          var form = fp.getForm();
          if(form.isValid()) {
            form.submit({
              url: config.url,
              fileUpload: true,
              success: function() {
                fp.ownerCt.destroy();
                /* put up an alert letting them know we did it */
                /* or make the page reload... */
                config.store.reload();
              }
            });
          }
        }
      }, {
        text: 'Cancel',
        type: 'submit',
        handler: function(f) {
          var fp = this.ownerCt.ownerCt;
          fp.ownerCt.destroy();
        }
      }],
      fileUpload: true,
      url: config.url,
      items: [{
        xtype: 'textfield',
        inputType: 'file',
        name: 'file[file]',
        fieldLabel: 'File'
      }, {
        xtype: 'combo',
        fieldLabel: 'Group',
        name: 'file[group]',
        mode: 'local',
        editable: true,
        triggerAction: 'all',
        forceSelection: true,
        typeAhead: true,
        lazyRender: true,
        emptyText: "Which group will see this file?",
        store: groups,
        valueField: 'id',
        displayField: 'name',
        value: config.group,
        listEmptyText: "No Groups Available",
        hiddenName: 'file[group_id]'
      }, {
        xtype: 'textfield',
        name: 'file[display_name]',
        fieldLabel: 'Display Name'
      }, {
        inputType: 'hidden',
        xtype: 'field',
        name: 'authenticity_token',
        value: config.form_authenticity_token
      }, {
        xtype: 'textfield',
        name: 'file[tags]',
        fieldLabel: 'Tags'
      }, {
        xtype: 'textarea',
        name: 'file[description]',
        width: 350,
        fieldLabel: 'Description'
      }]
    }];
            Ext.apply(this, config);
        }

       Locker.ux.FileUploadWindow.superclass.constructor.call(this);
    }
  });

  Ext.ComponentMgr.registerType('locker-uploadwindow', Locker.ux.FileUploadWindow);

  var s = $('success');

  if(s) {
    Effect.Fade(s, { delay: 3.0, duration: 3.0 });
  }
});
