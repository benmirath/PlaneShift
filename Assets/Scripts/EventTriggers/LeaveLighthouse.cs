using UnityEngine;
using System.Collections;

public class LeaveLighthouse : MonoBehaviour {
	public Material[] mats;
	void OnTriggerEnter (Collider hit) {
		if (hit.CompareTag ("Player"))
			StartCoroutine (ScaleColor (Color.white));
	}
	void OnTriggerExit (Collider hit) {
		if (hit.CompareTag ("Player"))
			StartCoroutine (ScaleColor (Color.black));
	}
	IEnumerator ScaleColor (Color newColor) {
		float counter = 0;
		float duration = 1f;
		while (counter < duration) {
			for (int i = 0; i < mats.Length; i++) {
				mats[i].color = Color.Lerp (mats[i].color, newColor, counter / duration);
				counter += Time.deltaTime;
			}

			yield return null;
		} 
		for (int i = 0; i < mats.Length; i++) {
			mats[i].color = newColor;
		}
	}
}
