using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Collections;

/// <summary>
///this class describes item ( service or profession ) 
///for reception hours - UC GridReceptionHoursUC.ascx
/// </summary>
[Serializable]
public class Item
{
  public  enum ItemType 
    {
        service = 1,
        profession = 2
    }
    private int _deptCode = -1;
    private int _itemID = -1;
    private string  _itemName = string.Empty;
    private ItemType _itemType;
    private string _receptionID = string.Empty;
    private bool _isSelected = false;

    public Item(int p_deptCode, int p_itemID, string p_receptionID, bool p_isSelected)
    {
        this.deptCode = p_deptCode;
        this.itemID = p_itemID;
        this.receptionID = p_receptionID;
        this.isSelected = p_isSelected;
    }

    public Item()
    {
    }


    public bool isSelected
    {
        get
        {
            return _isSelected;
        }

        set
        {
            _isSelected = value;
        }
    }


    public string receptionID
    {
        get
        {
            return _receptionID;
        }

        set
        {
            _receptionID = value;
        }
    }


    public ItemType itemType
    {
        get
        {
            return _itemType;
        }

        set
        {
            _itemType = value;
        }
    }

    public string  itemName
    {
        get
        {
            return _itemName;
        }

        set
        {
            _itemName = value;
        }
    }


    public int itemID
    {
        get
        {
            return _itemID;
        }

        set
        {
            _itemID = value;
        }
    }

    public int deptCode
    { 
        get
        {
            return _deptCode;
        }
          
        set
        {
            _deptCode = value;
        }
    }

}

[Serializable]
public class Items : CollectionBase
{
    private object[] _contents = new object[0];
    private int _count;

    public Items(): base()
    {
    }


    public void Add(Item  obj)
    {
        this.List.Add(obj);
    }


    /// <summary> 
    /// Get or set a primitive object by index 
    /// </summary> 
    public Item this[int index]
    {
        get
        {
            return (Item)List[index];
        }
        set
        {
            List[index] = value;
        }
    }

    /// <summary> 
    /// Remove a Thumbnail object from the collection. 
    /// </summary> 
    /// <param name="o"></param> 
    public void Remove(Item obj)
    {
        List.Remove(obj);
    }

    public void Insert(int indx, Item obj)
    {
        List.Insert(indx, obj);
    }
    public bool ContainsKey(int key)
    {
        foreach (Item item in this.List)
        {
            if (item.itemID == key)
                return true;          
        }
        return false;
    }

    public Item GetByKey(int key)
    {
        foreach (Item item in this.List)
        {
            if (item.itemID == key)
                return item;           
        }
        return null;
    }

    public int IndexOf(Item item)
    {
        return (List.IndexOf(item));
    }

   
}
