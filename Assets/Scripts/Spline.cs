using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Spline : MonoBehaviour {
    public List<GameObject> points;
    public int nbrPoints = 50;
    LineRenderer line;
    List<Vector3> positions;
	// Use this for initialization
	void Start () {
        positions = new List<Vector3>();
        line = GetComponent<LineRenderer>();
       
    }
	
	// Update is called once per frame
	void Update () {
        positions.Clear();
        Vector3 pc = points[0].transform.position * 0.125f + points[1].transform.position + points[2].transform.position * 0.125f;
        Vector3 tmpP1 = 2 * pc - points[0].transform.position / 2 - points[2].transform.position / 2;
        for (float i = 0; i < 1; i += (float)1 / (float)nbrPoints)
        {
            //positions.Add(points[0].transform.position * Mathf.Pow(1 - i, 3) + 3 * points[1].transform.position * i * Mathf.Pow(1 - i, 2) + 3 * points[2].transform.position * Mathf.Pow(i, 2) * (1 - i) + points[3].transform.position * Mathf.Pow(i, 3));
            positions.Add(points[2].transform.position * (i * i) + tmpP1 * 2 * i  * (1 - i) + points[0].transform.position * (1 - i) * (1 - i));
        }
        line.positionCount = positions.Count;
        line.SetPositions(positions.ToArray());
    }
}
