/*
 * Copyright 2018-present Open Networking Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import {
    Directive,
    ElementRef,
    EventEmitter,
    Input,
    OnChanges, Output
} from '@angular/core';
import {ForceDirectedGraph, Node} from '../models';
import * as d3 from 'd3';
import {LogService, MetaUi, ZoomUtils} from 'org_onosproject_onos/web/gui-fw-lib/public_api';
import {BackgroundSvgComponent} from '../../backgroundsvg/backgroundsvg.component';

@Directive({
  selector: '[onosDraggableNode]'
})
export class DraggableDirective implements OnChanges {
    @Input() draggableNode: Node;
    @Input() draggableInGraph: ForceDirectedGraph;
    @Output() newLocation = new EventEmitter<MetaUi>();

    constructor(
        private _element: ElementRef,
        private log: LogService
    ) {
        this.log.debug('DraggableDirective constructed');
    }

    ngOnChanges() {
        this.applyDraggableBehaviour(
            this._element.nativeElement,
            this.draggableNode,
            this.draggableInGraph,
            this.newLocation);
    }

    /**
     * A method to bind a draggable behaviour to an svg element
     */
    applyDraggableBehaviour(element, node: Node, graph: ForceDirectedGraph, newLocation: EventEmitter<MetaUi>) {
        const d3element = d3.select(element);

        // D3 v7: drag callbacks receive (event, d) directly — d3.event is removed.
        // All event handlers (start/drag/end) must be registered upfront on d3.drag().
        function started(event: d3.D3DragEvent<Element, any, any>) {
            /** Preventing propagation of dragstart to parent elements */
            event.sourceEvent.stopPropagation();

            if (!event.active) {
                graph.simulation.alphaTarget(0.3).restart();
            }
        }

        function dragged(event: d3.D3DragEvent<Element, any, any>) {
            node.fx = event.x;
            node.fy = event.y;
        }

        function ended(event: d3.D3DragEvent<Element, any, any>) {
            if (!event.active) {
                graph.simulation.alphaTarget(0);
            }
            newLocation.emit(ZoomUtils.convertXYtoGeo(node.fx, node.fy));

            // node.fx = null;
            // node.fy = null;
        }

        d3element.call(d3.drag()
            .on('start', started)
            .on('drag', dragged)
            .on('end', ended));
    }
}
