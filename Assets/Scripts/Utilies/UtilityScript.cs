﻿using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public static class UtilityScript {



}

// public class ObjectPool<T> where T : MonoBehaviour{
[System.Serializable]
public class ObjectPool<T> where T : Component {
	public ObjectPool (T prefabObj) {
		objectPrefab = prefabObj;
	}
	
	T objectPrefab;
	List<T> objectPool = new List<T> ();
	public T SpawnFromPool (Vector3 pos = default(Vector3)) {
		if (objectPrefab == null) return null;
		T returnObj = null;
		for (int i = 0; i < objectPool.Count; i++) {
			if (!objectPool[i].gameObject.activeInHierarchy) {
				returnObj = objectPool[i];
				returnObj.gameObject.SetActive (true);
				break;
			}
		}		
		if (returnObj == null) {
			returnObj = GameObject.Instantiate (objectPrefab, pos, Quaternion.identity) as T;
			objectPool.Add (returnObj);
		}
		return returnObj;
	}
	public void DeactivatePool () {
		Debug.LogError ("CLEARING");
		for (int i = 0; i < objectPool.Count; i++) {
			// Debug.LogError (objectPrefab.name + " : " + i);
			if (objectPool[i].gameObject.activeInHierarchy) {
				objectPool[i].transform.parent = null;
				objectPool[i].gameObject.SetActive (false);
				// break;
			}
		}
	}
	
}

